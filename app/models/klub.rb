require 'pry' if Rails.env.test?


class Klub < ActiveRecord::Base

  has_many :branches, class_name: 'Klub', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Klub', touch: true
  has_many :updates, as: :updatable

	before_save :update_slug
	before_save :update_complete

	validates :slug, uniqueness: true
	validates :name, presence: true

	scope :completed, -> { where(complete: true) }

  geocoded_by :address do |obj,results|
    if geo = results.first
      obj.town = geo.city
      obj.address = geo.formatted_address
      obj.latitude = geo.latitude
      obj.longitude = geo.longitude
      obj.save!  # Only needed if after create
    end
  end
  after_create :geocode, :if => :has_address?, :unless => :has_lat_lng_town_and_address?

  def merge_with(klub_attrs)

    basic_attrs = [:name, :address, :town, :phone, :email, :website, :facebook_url]
    array_attrs = [:categories]

    klub_attrs.each do |key, val|
      if basic_attrs.include?(key)

        if self[key].blank?
          self[key] = val
        end

      elsif array_attrs.include?(key)
        self[key] = (self[key] + klub_attrs[key]).uniq
      end
    end
  end

  def send_review_notification
    KlubMailer.new_klub_mail(self.id).deliver_later
  end

  def send_thanks_notification(editor)
    KlubMailer.new_klub_thanks_mail(self.id, editor).deliver_later
  end

  def send_updates_notification(updates)
    KlubMailer.new_updates_mail(self.name, updates).deliver_later
  end

  def send_confirm_notification(editor, updates)
    KlubMailer.confirmation_for_pending_updates_mail(self.id, editor, updates.map(&:id)).deliver_later
  end

  def send_updates_accepted_notification(editor, updates)
    KlubMailer.confirmation_for_acceped_updates_mail(self.id, editor, updates.map(&:id)).deliver_later
  end

  def create_updates(new_attrs)
    editor = new_attrs['editor']
    updates = []
    new_attrs.except('editor').each do |key, val|
      next if self.send(key) == val
      updates << Update.create(
        updatable: self,
        field: key,
        oldvalue: self.send(key).to_s,
        newvalue: val.to_s,
        editor_email: editor
      )
    end
    updates
  end

  def spa_url
    "#{ENV['WEBSITE_FULL_HOST']}/#{self.categories.first}/#{self.slug}/".freeze
  end

  def spa_edit_url
    "#{ENV['WEBSITE_FULL_HOST']}/#{self.categories.first}/#{self.slug}/uredi/".freeze
  end

private
	def update_complete
		self.complete = !(self.name.blank? ||
                      self.latitude.nil? ||
                      self.longitude.nil?) &&
                    self.verified?
		nil
	end

	def generate_slug(slug)
		slug + "-" + Randgen.last_name.downcase
	end

	def update_slug
		slug = self.name.parameterize

		trySlug = slug
		while slug_taken(trySlug)
			trySlug = generate_slug(slug)
		end

		self.slug = trySlug
		nil
	end

	def slug_taken(slug)
		klub = Klub.unscoped.where(slug: slug).first
		return false unless klub
		return false if klub.id == self.id
		true
	end

  def has_address?
    !self.address.blank?
  end

  def has_lat_lng_town_and_address?
    return has_address? && self.latitude? && self.longitude? && self.town?
  end
end

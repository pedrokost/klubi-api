require 'pry' if Rails.env.test?


class Klub < ActiveRecord::Base

  has_many :branches, class_name: 'Klub', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Klub', touch: true
  has_many :updates, as: :updatable, dependent: :destroy

	before_save :update_slug
	before_save :update_complete

	validates :name, presence: true
  validates :categories, presence: true

	scope :completed, -> { where(complete: true) }

  geocoded_by :address do |obj,results|
    if geo = results.first
      obj.town = geo.city || geo.state
      obj.address = geo.formatted_address
      obj.latitude = geo.latitude
      obj.longitude = geo.longitude
      obj.save!  # Only needed if after create
    end
  end
  after_create :geocode, :if => :has_address?, :unless => :has_lat_lng_town_and_address?

  def merge_with(klub_attrs, skip: [])

    basic_attrs = [:name, :address, :town, :phone, :email, :website, :facebook_url] - skip
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

  def send_request_verify_klub_data_mail
    return if self.email.blank?
    KlubMailer.request_verify_klub_mail(self.id, self.email).deliver_later
    self.update_attribute :last_verification_reminder_at, DateTime.now
  end

  def create_updates(new_attrs)
    editor = new_attrs[:editor]
    updates = []

    new_attrs.except(:editor).each do |key, val|
      next if self.send(key) == val

      updates << Update.create!(
        updatable: self,
        field: key,
        oldvalue: self.send(key).to_s,
        newvalue: val.to_s,
        editor_email: editor
      )
    end
    updates
  end

  def url_slug
    "#{slug}-#{id}"
  end

  def spa_url
    "#{ENV['WEBSITE_FULL_HOST']}/#{self.categories.first}/#{self.url_slug}/".freeze
  end

  def spa_edit_url
    "#{ENV['WEBSITE_FULL_HOST']}/#{self.categories.first}/#{self.url_slug}/uredi/".freeze
  end

  def static_map_url(width: 400, height: 300)
    "https://maps.googleapis.com/maps/api/staticmap?center=#{self.latitude},#{self.longitude}&zoom=15&size=#{width}x#{height}&maptype=roadmap&markers=color:blue%7Clabel:%7C#{self.latitude},#{self.longitude}&key=#{ENV['GOOGLE_STATIC_MAPS_SERVER_API_KEY']}".html_safe.freeze
  end

private
	def update_complete
		self.complete = !(self.name.blank? ||
                      self.latitude.nil? ||
                      self.longitude.nil?) &&
                    self.verified?
		nil
	end

	def update_slug
		self.slug = self.name.parameterize
		nil
	end

  def has_address?
    !self.address.blank?
  end

  def has_lat_lng_town_and_address?
    return has_address? && self.latitude? && self.longitude? && self.town?
  end
end

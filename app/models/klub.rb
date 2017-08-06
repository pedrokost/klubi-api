require 'pry' if Rails.env.test?


class Klub < ActiveRecord::Base

  has_many :branches, class_name: 'Klub', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Klub', touch: true
  has_many :updates, as: :updatable, dependent: :destroy

	before_save :update_slug
	before_save :update_complete

	validates :name, presence: true
  validates :categories, presence: true
  validate :closed_at_cannot_be_in_the_future

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

  def send_on_create_notifications editor
    send_review_notification
    send_thanks_notification editor if editor
  end

  def send_on_update_notifications(editor, updates, new_branches)
    send_updates_notification(editor)
    send_confirm_notification(editor, updates, new_branches) if editor
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
    lat_lon_min_eta = 0.00001

    new_attrs.except(:editor, :id).each do |key, val|
      next if self.send(key) == val
      next if key == :latitude and (val - self.send(key)).abs < lat_lon_min_eta
      next if key == :longitude and (val - self.send(key)).abs < lat_lon_min_eta
      val = val.map(&:parameterize) if key == "categories"

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

  def suggest_branch_removal(branch_id, editor)
    branch = self.branches.find(branch_id)
    return false unless branch

    Update.create!(
      updatable: branch,
      field: 'marked_for_deletion',
      oldvalue: false,
      newvalue: true,
      editor_email: editor
    )
  end

  def url_slug
    "#{slug}-#{id}"
  end

  def spa_url
    "#{ENV['WEBSITE_FULL_HOST']}/#{category_for_url}/#{self.url_slug}/".freeze
  end

  def spa_edit_url
    "#{ENV['WEBSITE_FULL_HOST']}/#{category_for_url}/#{self.url_slug}/uredi/".freeze
  end

  def static_map_url(width: 400, height: 300)
    "https://maps.googleapis.com/maps/api/staticmap?center=#{self.latitude},#{self.longitude}&zoom=15&size=#{width}x#{height}&maptype=roadmap&markers=color:blue%7Clabel:%7C#{self.latitude},#{self.longitude}&key=#{ENV['GOOGLE_STATIC_MAPS_SERVER_API_KEY']}".html_safe.freeze
  end

  def created_branch branch_attrs
    return false if branch_attrs[:address].blank? || branch_attrs[:latitude].blank? || branch_attrs[:longitude].blank? || branch_attrs[:town].blank?

    branch = Klub.new(self.attributes
      .merge( verified: false )
      .except("id", "created_at", "updated_at")
      .merge(branch_attrs)
    )

    self.branches << branch

    branch
  end

private

  def supported_categories
    ENV['SUPPORTED_CATEGORIES'].split(',')
  end

  def category_for_url
    category = self.categories.first

    ok_categories = self.categories & supported_categories

    category = ok_categories.first if ok_categories.length > 0

    category
  end

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

  def send_review_notification
    KlubMailer.new_klub_mail(self.id).deliver_later
  end

  def send_thanks_notification(editor)
    KlubMailer.new_klub_thanks_mail(self.id, editor).deliver_later
  end

  def send_updates_notification(editor)
    KlubMailer.new_updates_mail(self.id, editor).deliver_later
  end

  def send_confirm_notification(editor, updates, new_branches)
    KlubMailer.confirmation_for_pending_updates_mail(self.id, editor, updates.map(&:id), new_branches.map(&:id)).deliver_later
  end

  def closed_at_cannot_be_in_the_future
    errors.add(:closed_at, "can't be in the future") if
      !closed_at.blank? and closed_at > Date.today
  end
end

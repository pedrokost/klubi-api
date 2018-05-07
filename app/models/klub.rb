require 'pry' if Rails.env.test?
require 'facebook_image_retriever'
require 'google_analytics_fetcher'

class Klub < ApplicationRecord
  has_many :branches, class_name: 'Klub', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Klub', touch: true, optional: true
  has_many :updates, as: :updatable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :comment_requests, as: :commentable, dependent: :destroy

  before_save :update_slug
  before_save :update_complete

  validates :name, presence: true
  validates :categories, presence: true
  validate :closed_at_cannot_be_in_the_future

  scope :completed, -> { where(complete: true) }

  geocoded_by :address do |obj, results|
    if geo = results.first
      obj.town = geo.city || geo.state
      obj.address = geo.formatted_address
      obj.latitude = geo.latitude
      obj.longitude = geo.longitude
      obj.save! # Only needed if after create
    end
  end
  after_create :geocode, if: :has_address?, unless: :has_lat_lng_town_and_address?

  def merge_left_with(klub_attrs, skip: [])
    # uses new data to fill in missing spots only, preferring old data
    basic_attrs = %i[name address town phone email website facebook_url] - skip
    array_attrs = [:categories]

    klub_attrs.each do |key, val|
      if basic_attrs.include?(key)
        self[key] = val if self[key].blank?
      elsif array_attrs.include?(key)
        self[key] = (self[key] + klub_attrs[key]).uniq
      end
    end
  end

  def merge_right_with(new_attrs, skip: [])
    # uses old data to fill in missing spots in new data, preferring new data
    basic_attrs = %i[name address town phone email website facebook_url] - skip
    array_attrs = [:categories]

    new_attrs.each do |key, val|
      if basic_attrs.include?(key)
        self[key] = val unless val.blank?
      elsif array_attrs.include?(key)
        self[key] = (new_attrs[key] + self[key]).uniq
      end
    end
  end

  def send_on_create_notifications(editor)
    send_review_notification
    send_thanks_notification editor if editor
  end

  def send_on_update_notifications(editor, updates, new_branches)
    send_updates_notification(editor)
    send_confirm_notification(editor, updates, new_branches) if editor
  end

  def send_updates_accepted_notification(editor, updates)
    KlubMailer.confirmation_for_acceped_updates_mail(id, editor, updates.map(&:id)).deliver_now
  end

  def send_request_verify_klub_data_mail
    return if email.blank?

    generate_data_confirmation_request_hash!

    KlubMailer.request_verify_klub_mail(id, email).deliver_now
    update_attribute :last_verification_reminder_at, DateTime.now
  end

  def create_updates(new_attrs)
    editor = new_attrs[:editor]
    updates = []
    lat_lon_min_eta = 0.00001

    new_attrs.except(:editor, :id).each do |key, val|
      next if send(key).to_s == val.to_s
      next if (key.to_s == 'latitude') && ((val.to_f - send(key).to_f).abs < lat_lon_min_eta)
      next if (key.to_s == 'longitude') && ((val.to_f - send(key).to_f).abs < lat_lon_min_eta)
      val = val.map(&:parameterize) if key.to_s == 'categories'

      if key.to_s == 'notes'
        val = if send(key).blank?
                "#{Date.today}: #{val}"
              else
                "#{Date.today}: #{val}\n#{send(key)}"
              end
      end

      duplicate_update = Update.where(updatable: self, field: key, oldvalue: send(key).to_s, newvalue: val.to_s, editor_email: editor, status: Update.statuses[:unverified]).where('created_at >= ?', 1.month.ago)
      next if duplicate_update.exists?

      updates << Update.create!(
        updatable: self,
        field: key,
        oldvalue: send(key).to_s,
        newvalue: val.to_s,
        editor_email: editor
      )
    end
    updates
  end

  def suggest_branch_removal(branch_id, editor)
    branch = branches.find(branch_id)
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
    "#{ENV['WEBSITE_FULL_HOST']}/#{category_for_url}/#{url_slug}/".freeze
  end

  def spa_edit_url
    "#{ENV['WEBSITE_FULL_HOST']}/#{category_for_url}/#{url_slug}/uredi/".freeze
  end

  def spa_data_confirmation_url
    "#{ENV['WEBSITE_FULL_HOST']}/#{category_for_url}/#{url_slug}/confirm/#{data_confirmation_request_hash}".freeze
  end

  def static_map_url(width: 400, height: 300)
    "https://maps.googleapis.com/maps/api/staticmap?center=#{latitude},#{longitude}&zoom=15&size=#{width}x#{height}&maptype=roadmap&markers=color:blue%7Clabel:%7C#{latitude},#{longitude}&key=#{ENV['GOOGLE_STATIC_MAPS_SERVER_API_KEY']}".html_safe.freeze
  end

  def created_branch(branch_attrs)
    return nil if branch_attrs[:address].blank? || branch_attrs[:latitude].blank? || branch_attrs[:longitude].blank? || branch_attrs[:town].blank?

    branch = Klub.new(attributes
      .merge(verified: false)
      .except('id', 'created_at', 'updated_at')
      .merge(branch_attrs.to_h))

    branches << branch

    branch
  end

  def images
    return [] unless facebook_page_id

    FacebookImageRetriever.new(page_id: facebook_page_id).photos
  end

  def update_visits_count_if_outdated!
    return if visits_count_updated_at && visits_count_updated_at >= 1.day.ago.to_date
    update_visits_count!
  end

  def update_visits_count!
    return 0 unless persisted?
    count = GoogleAnalyticsFetcher.new.total_visitors(id)
    return unless count.nil?
    self.visits_count = count
    self.visits_count_updated_at = DateTime.now
    save!
  end


private

  def generate_data_confirmation_request_hash!
    self.data_confirmation_request_hash = SecureRandom.uuid
    self.save!
  end

  def facebook_page_id
    return nil if facebook_url.nil?
    return nil unless facebook_url.downcase.include?('facebook.com')

    facebook_page_id = facebook_url.split('?').first
    facebook_page_id = facebook_page_id.split('/').reject(&:empty?).reject do |c|
      %w[info about reviews photos videos notes posts community].include? c
    end.last

    number_id = facebook_page_id.split('-').last
    return number_id if number_id.match? '\d{8,}'

    facebook_page_id
  end

  def supported_categories
    ENV['SUPPORTED_CATEGORIES'].split(',')
  end

  def category_for_url
    category = categories.first

    ok_categories = categories & supported_categories

    category = ok_categories.first unless ok_categories.empty?

    category
  end

  def update_complete
    self.complete = !(name.blank? ||
                      latitude.nil? ||
                      longitude.nil?) &&
                    verified?
    nil
  end

  def update_slug
    self.slug = name.parameterize
    nil
  end

  def has_address?
    !address.blank?
  end

  def has_lat_lng_town_and_address?
    has_address? && latitude? && longitude? && town?
  end

  def send_review_notification
    KlubMailer.new_klub_mail(id).deliver_later
  end

  def send_thanks_notification(editor)
    KlubMailer.new_klub_thanks_mail(id, editor).deliver_later
  end

  def send_updates_notification(editor)
    KlubMailer.new_updates_mail(id, editor).deliver_later
  end

  def send_confirm_notification(editor, updates, new_branches)
    KlubMailer.confirmation_for_pending_updates_mail(id, editor, updates.map(&:id), new_branches.map(&:id)).deliver_later
  end

  def closed_at_cannot_be_in_the_future
    errors.add(:closed_at, "can't be in the future") if
      !closed_at.blank? && (closed_at > Date.today)
  end
end

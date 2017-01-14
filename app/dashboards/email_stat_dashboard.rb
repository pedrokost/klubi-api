require "administrate/base_dashboard"

class EmailStatDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    last_opened_at: Field::DateTime,
    last_clicked_at: Field::DateTime,
    last_bounced_at: Field::DateTime,
    last_dropped_at: Field::DateTime,
    last_delivered_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    email: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :email,
    :last_delivered_at,
    :last_bounced_at,
    :last_dropped_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :last_opened_at,
    :last_clicked_at,
    :last_bounced_at,
    :last_dropped_at,
    :last_delivered_at,
    :created_at,
    :updated_at,
    :email,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :last_opened_at,
    :last_clicked_at,
    :last_bounced_at,
    :last_dropped_at,
    :last_delivered_at,
    :email,
  ].freeze

  # Overwrite this method to customize how email stats are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(email_stat)
  #   "EmailStat ##{email_stat.id}"
  # end
end

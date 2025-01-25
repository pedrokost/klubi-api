require "administrate/base_dashboard"

class KlubDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    address: Field::String,
    branches: Field::HasMany,
    categories: Field::String,
    closed_at: Field::Date,
    comment_requests: Field::HasMany,
    comments: Field::HasMany,
    complete: Field::Boolean,
    data_confirmation_request_hash: Field::String,
    data_confirmed_at: Field::DateTime,
    description: Field::String,
    editor_emails: Field::String,
    email: Field::String,
    facebook_url: Field::String,
    last_verification_reminder_at: Field::DateTime,
    latitude: Field::String.with_options(searchable: false),
    longitude: Field::String.with_options(searchable: false),
    name: Field::String,
    notes: Field::String,
    parent: Field::BelongsTo,
    phone: Field::String,
    slug: Field::String,
    town: Field::String,
    updates: Field::HasMany,
    verified: Field::Boolean,
    visits_count: Field::Number,
    visits_count_updated_at: Field::DateTime,
    website: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    name
    town
    complete
    updates
    verified
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    address
    branches
    categories
    closed_at
    comment_requests
    comments
    complete
    data_confirmation_request_hash
    data_confirmed_at
    description
    editor_emails
    email
    facebook_url
    last_verification_reminder_at
    latitude
    longitude
    name
    notes
    parent
    phone
    slug
    town
    updates
    verified
    visits_count
    visits_count_updated_at
    website
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    address
    branches
    categories
    closed_at
    comment_requests
    comments
    complete
    data_confirmation_request_hash
    data_confirmed_at
    description
    editor_emails
    email
    facebook_url
    last_verification_reminder_at
    latitude
    longitude
    name
    notes
    parent
    phone
    slug
    town
    updates
    verified
    visits_count
    visits_count_updated_at
    website
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how klubs are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(klub)
    "#{klub.name}"
  end
end

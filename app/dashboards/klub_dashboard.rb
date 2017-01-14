require "administrate/base_dashboard"

class KlubDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    branches: Field::HasMany.with_options(class_name: "Klub", searchable: false),
    parent: Field::BelongsTo.with_options(class_name: "Klub", searchable: false),
    updates: Field::HasMany.with_options(searchable: false),
    id: Field::Number.with_options(searchable: false),
    name: Field::String.with_options(searchable: true),
    slug: Field::String.with_options(searchable: true),
    address: Field::String.with_options(searchable: true),
    town: Field::String.with_options(searchable: true),
    website: Field::String.with_options(searchable: true),
    phone: Field::String.with_options(searchable: true),
    email: Field::String.with_options(searchable: true),
    notes: Field::String.with_options(searchable: true),
    latitude: Field::String.with_options(searchable: false),
    longitude: Field::String.with_options(searchable: false),
    created_at: Field::DateTime.with_options(searchable: false),
    updated_at: Field::DateTime.with_options(searchable: false),
    verified: Field::Boolean.with_options(searchable: false),
    complete: Field::Boolean.with_options(searchable: false),
    categories: Field::String.with_options(searchable: false),
    facebook_url: Field::String.with_options(searchable: true),
    editor_emails: Field::String.with_options(searchable: false),
    parent_id: Field::Number.with_options(searchable: false),
    last_verification_reminder_at: Field::DateTime.with_options(searchable: false)
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :name,
    :town,
    :complete,
    :updates,
    :verified
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :verified,
    :name,
    :slug,
    :address,
    :website,
    :phone,
    :email,
    :categories,
    :facebook_url,
    :editor_emails,
    :notes,
    :branches
  ].freeze

  # Overwrite this method to customize how klubs are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(klub)
    "#{klub.name}"
  end
end

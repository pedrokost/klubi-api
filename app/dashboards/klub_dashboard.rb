require "administrate/base_dashboard"

class KlubDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    branches: Field::HasMany.with_options(class_name: "Klub"),
    parent: Field::BelongsTo.with_options(class_name: "Klub"),
    updates: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    slug: Field::String,
    address: Field::String,
    town: Field::String,
    website: Field::String,
    phone: Field::String,
    email: Field::String,
    latitude: Field::String.with_options(searchable: false),
    longitude: Field::String.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    complete: Field::Boolean,
    categories: Field::String,
    facebook_url: Field::String,
    editor_emails: Field::String,
    parent_id: Field::Number,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :name,
    :town,
    :complete,
    :updates
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :branches,
    :parent,
    :updates,
    :name,
    :slug,
    :address,
    :town,
    :website,
    :phone,
    :email,
    :latitude,
    :longitude,
    :complete,
    :categories,
    :facebook_url,
    :editor_emails,
    :parent_id,
  ]

  # Overwrite this method to customize how klubs are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(klub)
    "#{klub.name}"
  end
end

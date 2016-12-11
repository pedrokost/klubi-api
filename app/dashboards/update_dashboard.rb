require "administrate/base_dashboard"

class UpdateDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    updatable: Field::Polymorphic,
    id: Field::Number,
    field: Field::String,
    oldvalue: Field::String,
    newvalue: Field::String,
    status: Field::String.with_options(searchable: false),
    editor_email: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    acceptance_email_sent: Field::Boolean.with_options(searchable: false),
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :updatable,
    :field,
    :oldvalue,
    :newvalue,
    :status
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys - [:id, :updated_at]

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :updatable,
    :oldvalue,
    :newvalue,
    :status,
    :editor_email,
  ]

  # Overwrite this method to customize how updates are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(update)
  #   "Update ##{update.id}"
  # end
end

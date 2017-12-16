require "administrate/base_dashboard"

class CommentRequestDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    commentable: Field::Polymorphic,
    comment: Field::BelongsTo,
    id: Field::Number,
    requester_email: Field::String,
    commenter_email: Field::String,
    request_hash: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :commentable,
    :requester_email,
    :commenter_email,
    :comment
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :commentable,
    :comment,
    :requester_email,
    :commenter_email,
    :request_hash,
    :created_at,
    :updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :commentable,
    :requester_email,
    :commenter_email
  ].freeze

  # Overwrite this method to customize how comment requests are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(comment_request)
  #   "CommentRequest ##{comment_request.id}"
  # end
end

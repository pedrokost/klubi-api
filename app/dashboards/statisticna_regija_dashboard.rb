require "administrate/base_dashboard"

class StatisticnaRegijaDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    obcinas: Field::HasMany,
    name: Field::String,
    slug: Field::String,
    population_size: Field::Number,
    geom: Field::String.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :name,
    :slug,
    :population_size,
    :obcinas
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :name,
    :slug,
    :obcinas,
    :population_size,
    # :geom,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :slug,
    :obcinas,
    :population_size
    # :geom,
  ].freeze

  # Overwrite this method to customize how statisticna regijas are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(statisticna_regija)
    statisticna_regija.to_s
  end
end

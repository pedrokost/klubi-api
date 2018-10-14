class Obcina < ApplicationRecord
  belongs_to :statisticna_regija, touch: true, optional: true

  def url_slug
    "#{slug}-#{id}"
  end

  def to_s
    name
  end

  def category_klubs(category = nil)
    # Returns list of all klubs in the region of given category
    search_categories = category.blank? ? supported_categories : category

    klubs.where("categories && ARRAY[?]::varchar[]", search_categories)
  end

  def neighbouring_obcinas
    # select * from obcinas o WHERE ST_Touches(o.geom::geometry, (SELECT geom::geometry from obcinas WHERE id=235));
    Obcina.where.not(
      %{
        ST_Disjoint(
          geom::geometry,
          (SELECT geom::geometry from obcinas WHERE id=%d)
        )
      } % [self.id]
    ).where.not("id=?", self.id).order(population_size: :desc)
  end

private

  def supported_categories
    ENV['SUPPORTED_CATEGORIES'].split(',').freeze
  end

  def klubs
    # Return list of all klubs in the region
    Klub.completed.where('closed_at IS NULL').where(
      %{
        ST_Intersects(
          (SELECT geom FROM obcinas WHERE id=%d),
          ST_GeographyFromText(
            'SRID=4326;POINT(' || longitude || ' ' || latitude || ')'
          )
        )
      } % [self.id]
    )
  end
end

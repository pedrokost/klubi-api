class Obcina < ActiveRecord::Base
  belongs_to :statisticna_regija, touch: true

  def url_slug
    "#{slug}-#{id}"
  end

  def to_s
    name
  end

  def category_klubs(category)
    # Returns list of all klubs in the region of given category
    klubs.where("? = ANY (categories)", category)
  end

private

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

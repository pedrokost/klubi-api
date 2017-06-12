class AddPointIndexToKlubs < ActiveRecord::Migration
  def up
      execute %{
        create index index_on_klubs_location ON klubs using gist (
          ST_GeographyFromText(
            'SRID=4326;POINT(' || klubs.longitude || ' ' || klubs.latitude || ')'
          )
        )
      }
    end

    def down
      execute %{drop index index_on_klubs_location}
    end
end

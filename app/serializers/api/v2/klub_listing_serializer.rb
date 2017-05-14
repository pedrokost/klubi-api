module Api
  module V2
    class KlubListingSerializer < ActiveModel::Serializer
      cache key: 'v2/klub'
      attributes :name, :latitude, :longitude, :town, :categories

      def id
        object.url_slug
      end

      belongs_to :parent, serializer: KlubListingSerializer, type: :klubs
    end
  end
end

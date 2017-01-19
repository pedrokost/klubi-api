module Api
  module V2
    class KlubSerializer < ActiveModel::Serializer
      cache key: 'v2/klub'
      attributes :name, :address, :email, :latitude, :longitude, :phone, :town, :website, :facebook_url, :categories, :notes

      def id
        object.url_slug
      end

      belongs_to :parent, serializer: KlubSerializer
    end
  end
end

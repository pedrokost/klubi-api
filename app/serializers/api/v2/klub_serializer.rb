module Api
  module V2
    class KlubSerializer < ActiveModel::Serializer

      class BranchSerializer < ActiveModel::Serializer
        attributes :address, :latitude, :longitude
        def id
          object.url_slug
        end
      end


      cache key: 'v2/klub'
      attributes :name, :address, :email, :latitude, :longitude, :phone, :town, :website, :facebook_url, :categories, :notes, :verified

      def id
        object.url_slug
      end

      has_many :branches, serializer: BranchSerializer

      belongs_to :parent, serializer: KlubSerializer


    end
  end
end

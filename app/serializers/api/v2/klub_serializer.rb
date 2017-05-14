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
      attributes :name, :address, :email, :latitude, :longitude, :phone, :town, :website, :facebook_url, :categories, :notes, :verified, :closed_at

      has_many :branches, serializer: BranchSerializer

      belongs_to :parent, serializer: KlubSerializer, type: :klubs

      def id
        object.url_slug
      end

      def branches
        return object.branches unless object.verified
        object.branches.where(verified: true)
      end
    end
  end
end

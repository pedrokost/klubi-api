module Api
  module V2
    class KlubSerializer < ActiveModel::Serializer
      include Rails.application.routes.url_helpers

      class BranchSerializer < ActiveModel::Serializer
        attributes :address, :latitude, :longitude
        def id
          object.url_slug
        end
      end

      cache key: 'v2/klub'
      attributes :name, :address, :email, :latitude, :longitude, :phone, :town, :website, :facebook_url, :categories, :verified, :closed_at, :description

      has_many :branches, serializer: BranchSerializer

      has_many :comments

      # Cannot obtain Facebook permission for accessing public photos.
      # has_many :images do
      #   link(:related) { images_klub_url(object.url_slug) }
      #   include_data false
      # end

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

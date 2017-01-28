module Api
  module V1
    class KlubSerializer < ActiveModel::Serializer
      cache
      attributes :id, :name, :address, :email, :latitude, :longitude, :phone, :town, :website, :slug, :facebook_url, :categories, :parent_id, :notes

      def parent_id
        object.parent.try(:slug)
      end
    end
  end
end

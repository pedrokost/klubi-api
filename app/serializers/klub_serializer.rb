class KlubSerializer < ActiveModel::Serializer
  cache key: 'klub'
  attributes :id, :name, :address, :email, :latitude, :longitude, :phone, :town, :website, :slug, :facebook_url, :categories

end

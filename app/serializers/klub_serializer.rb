class KlubSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :email, :latitude, :longitude, :phone, :town, :website, :slug, :facebook_url

end

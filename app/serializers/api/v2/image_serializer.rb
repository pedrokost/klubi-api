class Api::V2::ImageSerializer < ActiveModel::Serializer
  attributes :type, :thumbnail, :large
end

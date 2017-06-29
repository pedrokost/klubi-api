class Api::V2::ObcinaSerializer < ActiveModel::Serializer

  class IncludedObcinaSerializer < ActiveModel::Serializer
    attributes :name
    def id
      object.url_slug
    end
  end



  attributes :name

  has_many :klubs, serializer: Api::V2::KlubListingSerializer
  has_many :neighbouring_obcinas, serializer: IncludedObcinaSerializer

  def id
    object.url_slug
  end

  def klubs
    object.category_klubs @instance_options[:category]
  end
end

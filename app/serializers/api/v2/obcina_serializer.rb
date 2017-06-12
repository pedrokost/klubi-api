class Api::V2::ObcinaSerializer < ActiveModel::Serializer
  attributes :name

  has_many :klubs, serializer: Api::V2::KlubListingSerializer


  def klubs
    object.category_klubs @instance_options[:category]
  end
end

class Api::V2::CommentRequestSerializer < ActiveModel::Serializer
  attributes :id

  def id
    object.request_hash
  end
end

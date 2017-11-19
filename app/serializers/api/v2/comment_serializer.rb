class Api::V2::CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :commenter_name
end

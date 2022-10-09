class Api::V2::OnlineTrainingEntrySerializer < ActiveModel::Serializer
  attributes :id, :title, :brief, :organizer, :categories, :is_priced

  def id
    object.url_slug
  end
end

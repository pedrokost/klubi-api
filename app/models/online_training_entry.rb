class OnlineTrainingEntry < ApplicationRecord

  def url_slug
    "#{slug}-#{id}"
  end

  def to_s
    title
  end

end

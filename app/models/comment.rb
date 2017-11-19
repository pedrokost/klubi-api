class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true

  def send_comment_published_email_to_commenter
    CommentMailer.thank_your_for_recommendation(self.id).deliver_later
  end
end

# Preview all emails at http://localhost:3000/rails/mailers/comments
class CommentPreview < ActionMailer::Preview

  def thank_your_for_recommendation
    comment = Comment.last
    CommentMailer.thank_your_for_recommendation(comment.id)
  end
end

# Preview all emails at http://localhost:3000/rails/mailers/comment_requests
class CommentRequestPreview < ActionMailer::Preview
  def new_recommendation_posted
    comment_request = CommentRequest.last
    CommentRequestMailer.new_recommendation_posted(comment_request.id)
  end

  def send_request
    comment_request = CommentRequest.last
    CommentRequestMailer.send_request(comment_request.id)
  end
end

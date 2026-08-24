class CommentRequestMailer < ApplicationMailer
  def send_request(comment_request_id)
    @comment_request = CommentRequest.find(comment_request_id)

    from_email = Rails.application.credentials.DEFAULT_BOT_EMAIL
    subject = "Priporoči #{@comment_request.commentable.name} 🏆🏆🏆"

    commenter_email = @comment_request.commenter_email
    bcc_email = Rails.application.credentials.DEFAULT_BCC_EMAIL

    mail(from: from_email, to: commenter_email, bcc: bcc_email, subject: subject)
  end

  def new_recommendation_posted(comment_request_id)
    @comment_request = CommentRequest.find(comment_request_id)

    @comment = @comment_request.comment

    from_email = Rails.application.credentials.DEFAULT_BOT_EMAIL
    subject = "🏆 #{@comment.commenter_name} je priporočil #{@comment.commentable.name} (و ˃̵ᴗ˂̵)و"

    requester_email = @comment_request.requester_email
    bcc_email = Rails.application.credentials.DEFAULT_BCC_EMAIL

    mail(from: from_email, to: requester_email, bcc: bcc_email, subject: subject)
  end
end

class CommentMailer < ApplicationMailer

  def thank_your_for_recommendation(comment_id)
    @comment = Comment.find(comment_id)

    from_email = ENV['DEFAULT_BOT_EMAIL']
    subject = "🏆 #{@comment.commentable.name} se ti zahvaljuje za priporočilo (-‿◦)"
    commenter_email = @comment.commenter_email
    bcc_email = ENV['DEFAULT_BCC_EMAIL']

    mail(from: from_email, to: commenter_email, bcc: bcc_email, subject: subject)
  end
end

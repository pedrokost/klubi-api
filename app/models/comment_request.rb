class CommentRequest < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :comment, optional: true

  before_create :generate_request_hash

  validates_uniqueness_of :commenter_email, scope: [:commentable]
  validates_presence_of :requester_name
  validates_presence_of :commenter_name
  validates_email_format_of :commenter_email
  validates_email_format_of :requester_email
  validates_presence_of :commentable_id
  validates_presence_of :commentable_type

  def send_comment_received_email_to_requestor
    CommentRequestMailer.new_recommendation_posted(self.id).deliver_later
  end

  def send_comment_request_email
    return unless self.persisted?
    CommentRequestMailer.send_request(self.id).deliver_later
  end

  def spa_url
    "#{self.commentable.spa_url}oddaj-mnenje/#{request_hash}".freeze
  end

private

  def generate_request_hash
    self.request_hash = SecureRandom.uuid unless self.request_hash
  end
end

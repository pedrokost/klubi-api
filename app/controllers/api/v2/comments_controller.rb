require 'json'

class Api::V2::CommentsController < ApplicationController

  before_action :select_ams_adapter

  def create
    comment_request = CommentRequest.where( request_hash: new_comment_params[:request_hash] ).first

    if comment_request.try(:comment)
      head 422 and return
    end

    comment = Comment.create(
      commentable: comment_request.commentable,
      body: new_comment_params[:body],
      commenter_name: new_comment_params[:commenter_name],
      commenter_email: comment_request.commenter_email
    )

    comment_request.comment = comment
    comment_request.save!

    comment_request.send_comment_received_email_to_requestor
    comment.send_comment_published_email_to_commenter

    render json: comment, status: :accepted
  end

private

  def new_comment_params
    parameters = ActionController::Parameters.new(
      ActiveModelSerializers::Deserialization.jsonapi_parse!(params)
    )
    parameters.require(:commenter_name)
    parameters.require(:body)
    parameters.require(:request_hash)

    parameters
  end

  def select_ams_adapter
    ActiveModelSerializers.config.adapter = :json_api
  end
end

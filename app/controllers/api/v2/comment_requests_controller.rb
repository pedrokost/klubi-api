class Api::V2::CommentRequestsController < ApplicationController

  before_action :select_ams_adapter

  def create
    klub = find_klub
    head :not_found and return unless klub

    comment_request = CommentRequest.where(
      commentable: klub,
      commenter_email: comment_request_params[:commenter_email]
    )
    if comment_request.exists?
      # Warning: This could leak requests from other people!
      comment_request = comment_request.first
    else
      comment_request = CommentRequest.new(comment_request_params.to_h.except(:klub_attributes))
      comment_request.commentable = klub
      comment_request.save!

      comment_request.send_comment_request_email
    end


    render json: comment_request, status: :accepted
  end

private

  def comment_request_params
    parameters = ActionController::Parameters.new(
      ActiveModelSerializers::Deserialization.jsonapi_parse!(params, embedded: [:klub])
    ).permit(:requester_email, :requester_name, :commenter_email, :commenter_name, :klub_attributes => [:id])
    parameters.require(:requester_email)
    parameters.require(:requester_name)
    parameters.require(:commenter_email)
    parameters.require(:commenter_name)
    parameters.require(:klub_attributes)

    parameters
  end

  def find_klub
    slug_with_id = comment_request_params[:klub_attributes][:id]
    id = slug_with_id.split('-').last
    Klub.find(id)
  end

  def select_ams_adapter
    ActiveModelSerializers.config.adapter = :json_api
  end
end

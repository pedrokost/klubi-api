class Api::V2::OnlineTrainingEntriesController < ApplicationController

  before_action :select_ams_adapter

  def index
    data = OnlineTrainingEntry.where(is_verified: true, terminated_at: nil)
    render json: data
  end

private

  def select_ams_adapter
    ActiveModelSerializers.config.adapter = :json_api
  end

end

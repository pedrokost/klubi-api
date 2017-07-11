class Api::V2::ObcinasController < ApplicationController

  before_action :select_ams_adapter

  def show
    obcina = find_obcina

    render json: obcina, include: [:klubs, :neighbouring_obcinas], category: category_params['category']
  end

private

  def select_ams_adapter
    ActiveModelSerializers.config.adapter = :json_api
  end

  def find_obcina
    slug_with_id = params[:id]
    id = slug_with_id.split('-').last
    Obcina.find(id)
  end

  def supported_categories
    ENV['SUPPORTED_CATEGORIES'].split(',')
  end

  def category_params
    params.permit(:category)
  end
end

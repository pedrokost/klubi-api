class Api::V2::ObcinasController < ApplicationController

  before_action :select_ams_adapter

  def show
    render json: nil, status: :not_found and return unless supported_categories.include? category_params

    obcina = find_obcina

    render json: obcina, include: [:klubs], category: category_params
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
    params.require(:category)
  end
end

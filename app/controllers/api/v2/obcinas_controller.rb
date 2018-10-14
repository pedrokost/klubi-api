class Api::V2::ObcinasController < ApplicationController

  before_action :select_ams_adapter

  def show
    obcina = find_obcina

    # neighbouring_obcinas is expensive to compute (relatively speaking).
    # I should cache it only, but it's simpler to cache the entire
    # API response. Because there is no simple invalidation policy (depends
    # on new/deleted/updates klubs) I use a simple time-based caching method.
    # AMS caching is broken.

    Rails.cache.fetch("v2/obcinas/#{obcina.slug}-#{obcina.id}", expires_in: 1.week) do
      render json: obcina, include: [:klubs, :neighbouring_obcinas], category: category_params['category']
    end
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

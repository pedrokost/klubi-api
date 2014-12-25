module Api
  module V1
    class KlubsController < ApplicationController
      def index
        @klubs = Klub.where("? = ANY (categories)", category_param)
        render json: @klubs
      end

    private

      def category_param
        params.require(:category)
      end
    end
  end
end


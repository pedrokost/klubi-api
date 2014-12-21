module Api
  module V1
    class KlubsController < ApplicationController
      def index
        if klub_params[:category]
          @klubs = Klub.where("? = ANY (categories)", klub_params[:category])
        else
          @klubs = Klub.all
        end
        render json: @klubs
      end

    private

      def klub_params
        params.permit(:category)
      end
    end
  end
end


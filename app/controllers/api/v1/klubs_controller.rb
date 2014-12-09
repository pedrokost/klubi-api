module Api
	module V1
		class KlubsController < ApplicationController
			def index
				@klubs = Klub.all
				render json: @klubs
			end

      def import
        # This action is meant for  import of data from scrapers,
        # not to be used by the SPA
        # It does not accept: duplicate names
        # It does: lat long computation if missing

        valid_referer = "zatresi.si"

        # p request.headers['headers']
        referer = request.headers['HTTP_REFERER']
        # referer = request.headers['Referer']
        referer = !referer.blank? ? referer : ''
        host = !referer.blank? ? URI::parse(referer).host : ''

        unless host && host.gsub(/^[^\.]*\./, '') == valid_referer
          render json: {}, status: :forbidden and return
        end


        if Klub.unscoped.where(name: klub_import_params['name']).empty?
          klub = Klub.new(klub_import_params)
          if klub.valid?
            # TODO: recompute lat/long if
            klub.save!
            render json: klub, status: :created
          else
            render json: {errors: klub.errors}, status: :unprocessable_entity
          end
        else
          render json: {}, status: :conflict
        end
      end

    private

      def klub_import_params
        params.require(:klub).permit(:name, :address, :website, :phone, :email, :latitude, :longitude, categories: [])
      end
		end
	end
end


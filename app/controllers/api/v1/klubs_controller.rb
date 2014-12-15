module Api
	module V1
		class KlubsController < ApplicationController
			def index
				@klubs = Klub.all
				render json: @klubs
			end
		end
	end
end


class ApplicationController < ActionController::API
	include ActionController::Serialization

	skip_before_filter :verify_authenticity_token
end

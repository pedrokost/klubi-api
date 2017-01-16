require 'rails-api'

class ApplicationController < ActionController::API
	include ActionController::Serialization

	skip_before_filter :verify_authenticity_token

  def index
    html = bootstrap_index(params[:index_key])
    render text: html
  end

  def heartbeat
    render 'application/heartbeat', :formats=>[:html]
  end

private

  def bootstrap_index(index_key)
    index_key ||= 'zatresi:current-content'
    REDIS.get(index_key)
  end

end

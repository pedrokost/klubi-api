# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    http_basic_authenticate_with name: ENV.fetch("ADMIN_NAME"), password: ENV.fetch("ADMIN_PASSWORD")

    before_action :set_locale
    before_action :authenticate_admin
    before_action :default_params

    def authenticate_admin
      # before_filter :authenticate_admin
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end

    def destroy
      requested_resource.destroy
      flash[:notice] = translate_with_resource("destroy.success")
      redirect_to action: :index, subdomain: 'admin'
    end

    def default_params
      params[:order] ||= "created_at"
      params[:direction] ||= "desc"
    end

    def set_locale
      I18n.locale = :en if Rails.env.production?
    end
  end
end

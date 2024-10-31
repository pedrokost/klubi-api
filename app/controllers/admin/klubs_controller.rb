module Admin
  class KlubsController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Klub.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Klub.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def toggleverify
      requested_resource.toggle!(:verified)

      if requested_resource.verified? && (requested_resource.data_confirmed_at.nil? || requested_resource.data_confirmed_at < requested_resource.created_at)
        requested_resource.update! data_confirmed_at: requested_resource.created_at
      end

      redirect_to(
        [:admin, requested_resource],
        notice: translate_with_resource("update.success")
      )
    end

    def send_data_verification_email
      requested_resource.send_request_verify_klub_data_mail
      redirect_to(
        [:admin, requested_resource],
        notice: "A verification email has just been sent to #{requested_resource.email}"
      )
    end

    def find_resource(param)
      resource_class.unscoped.find(param)
    end

    def resource_params
      # Transform string for storage as a Postgres array:
      params["klub"]["categories"] = params["klub"]["categories"].split(' ')
      params["klub"]["editor_emails"] = params["klub"]["editor_emails"].split(' ')
      params.require(resource_name).permit(dashboard.permitted_attributes, categories: [], editor_emails: [])
    end
  end
end

module Admin
  class KlubsController < Admin::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    # def update
    #   super
    #   send_foo_updated_email(requested_resource)
    # end

    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_resource(param)
    #   Foo.find_by!(slug: param)
    # end


    def default_sorting_attribute
      :updated_at
    end
  
    def default_sorting_direction
      :desc
    end

    # The result of this lookup will be available as `requested_resource`
    def toggleverify
      requested_resource.toggle!(:verified)

      if requested_resource.verified? && (requested_resource.data_confirmed_at.nil? || requested_resource.data_confirmed_at < requested_resource.created_at)
        requested_resource.update! data_confirmed_at: requested_resource.created_at
      end

      redirect_to(
        [:admin, requested_resource],
        notice: translate_with_resource("update.success"),
        allow_other_host: true
      )
    end

    def send_data_verification_email
      requested_resource.send_request_verify_klub_data_mail
      redirect_to(
        [:admin, requested_resource],
        notice: "A verification email has just been sent to #{requested_resource.email}",
        allow_other_host: true
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

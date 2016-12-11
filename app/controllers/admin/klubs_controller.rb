module Admin
  class KlubsController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Klub.all.paginate(10, params[:page])
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Klub.find_by!(slug: param)
    # end

    # See https://administrate-docs.herokuapp.com/customizing_controller_actions
    # for more information

    def toggleverify
      requested_resource.toggle!(:verified)

      redirect_to(
        [:admin, requested_resource],
        notice: translate_with_resource("update.success")
      )
    end

    def find_resource(param)
      resource_class.unscoped.find(param)
    end

    def resource_params
      # Transform string for storage as a Postgres array:
      params["klub"]["categories"] = params["klub"]["categories"].split(' ')
      params["klub"]["editor_emails"] = params["klub"]["editor_emails"].split(' ')
      params.require(resource_name).permit(*permitted_attributes, categories: [], editor_emails: [])
    end
  end
end

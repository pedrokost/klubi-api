module Admin
  class UpdatesController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Update.all.paginate(10, params[:page])
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Update.find_by!(slug: param)
    # end

    # See https://administrate-docs.herokuapp.com/customizing_controller_actions
    # for more information

    def reject
      requested_resource.reject!
      redirect_back(
        fallback_location: admin_update_path(requested_resource),
        notice: translate_with_resource("update.success")
      )
    end

    def accept
      requested_resource.accept!
      redirect_back(
        fallback_location: admin_update_path(requested_resource),
        notice: translate_with_resource("update.success")
      )
    end

    def update
      updated_success = false

      requested_resource.transaction do
        old_status = requested_resource.status
        if requested_resource.update(resource_params)

          if old_status != resource_params[:status]
            requested_resource.resolve!
          end

          updated_success = true
        end
      end

      if updated_success
        redirect_to(
          [:admin, requested_resource],
          notice: translate_with_resource("update.success"),
          allow_other_host: true
        )
      else
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard, requested_resource),
        }
      end
    end
  end
end

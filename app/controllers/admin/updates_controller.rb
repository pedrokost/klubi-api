module Admin
  class UpdatesController < Admin::ApplicationController
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
      :modified_at
    end
  
    def default_sorting_direction
      :desc
    end


    # The result of this lookup will be available as `requested_resource`
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

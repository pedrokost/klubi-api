module Api
  module V2
    class KlubsController < ApplicationController

      before_action :select_ams_adapter

      def index

        render json: [] and return unless supported_categories.include? category_params

        stats = Klub.select('count(*) as count, max(updated_at) as last_update_at').completed.where("? = ANY (categories)", category_params).where('closed_at IS NULL').order(nil).first

        data = Rails.cache.fetch("v2/klubs/#{category_params}-#{stats.count}-#{stats.last_update_at.to_i}") do
          klubs = Klub.completed.where("? = ANY (categories)", category_params).where('closed_at IS NULL')
          serializer = ActiveModel::Serializer::CollectionSerializer.new(klubs, serializer: Api::V2::KlubListingSerializer)
          ActiveModelSerializers::Adapter.create(serializer).to_json
        end

        render json: data
      end

      def create
        the_params = new_klub_params
        the_params[:categories] = the_params[:categories].map(&:parameterize) if the_params[:categories]

        klub = Klub.new(the_params.to_h.except(:editor, :branches_attributes))

        head 422 and return if the_params[:editor].blank?

        klub.editor_emails << the_params[:editor]

        head 422 and return unless klub.valid?

        # Create branches
        the_params[:branches_attributes].each do |branch_attrs|
          branch = klub.created_branch branch_attrs
          head 422 and return unless branch
        end

        # This helps not send verification reminders too soon
        if the_params[:email] == the_params[:editor]
          klub.last_verification_reminder_at = DateTime.now
        end

        klub.save!

        klub.send_on_create_notifications the_params[:editor]

        render json: klub, include: [:branches], status: :accepted
      end

      def update
        klub = find_klub

        editor = update_klub_params[:editor]
        head 422 and return if editor.blank?

        updates = klub.create_updates update_klub_params.except(:branches_attributes)

        # Delete any of the other branches
        updated_branch_ids = update_klub_params[:branches_attributes].select{ |branch| branch[:id] }.map{ |branch| extract_slug(branch[:id]).to_i }
        deleted_branch_ids = klub.branches.map(&:id) - updated_branch_ids

        deleted_branch_ids.each do |branch_id|
          updates << klub.suggest_branch_removal(branch_id, editor)
        end

        # Update existing branches
        new_branches = []
        update_klub_params[:branches_attributes].each do |branch_attrs|
          branch = find_by_url_slug branch_attrs[:id]
          if branch
            branch_updates = branch.create_updates branch_attrs.merge(editor: editor)
            updates.concat updates
          else
            branch = klub.created_branch branch_attrs
            new_branches << branch
          end
        end

        klub.save!

        klub.send_on_update_notifications editor, updates, new_branches

        render json: 'null', status: :accepted
      end

      def show
        klub = find_klub
        render json: klub, include: [:branches, :parent]
      end

      def images
        klub = find_klub
        images = Rails.cache.fetch("v2/klubs/#{klub.id}/images-#{Date.today.beginning_of_week}") do
          serializer = ActiveModel::Serializer::CollectionSerializer.new(klub.images, serializer: Api::V2::ImageSerializer)
          ActiveModelSerializers::Adapter.create(serializer).to_json
        end
        render json: images
      end

    private
      def find_klub
        slug_with_id = params[:id]
        id = slug_with_id.split('-').last
        Klub.find(id)
      end

      def find_by_url_slug url_slug
        return nil unless url_slug
        slug_with_id = url_slug
        id = slug_with_id.split('-').last
        Klub.find(id)
      end

      def extract_slug url_slug
        return nil unless url_slug
        url_slug.split('-').last
      end

      def category_params
        params.require(:category)
      end

      def supported_categories
        ENV['SUPPORTED_CATEGORIES'].split(',')
      end

      def new_klub_params
        parameters = ActionController::Parameters.new(
          ActiveModelSerializers::Deserialization.jsonapi_parse!(params,
            embedded: [:branches],
          )
        ).permit(
          :name,
          :address,
          :town,
          :latitude,
          :longitude,
          :website,
          :facebook_url,
          :phone,
          :email,
          :notes,
          :description,
          { :categories => [] },
          :editor,
          :branches_attributes => [:address, :latitude, :longitude, :town]
        )

        parameters[:branches_attributes] ||= []

        parameters
      end

      def update_klub_params
        parameters = ActionController::Parameters.new(
          ActiveModelSerializers::Deserialization.jsonapi_parse!(params,
            embedded: [:branches],
          )
        ).permit(
          :name,
          :address,
          :town,
          :latitude,
          :longitude,
          :website,
          :facebook_url,
          :phone,
          :email,
          :notes,
          :description,
          { :categories => [] },
          :editor,
          :branches_attributes => [:id, :address, :latitude, :longitude, :town]
        )

        parameters[:branches_attributes] ||= []

        parameters
      end

      def select_ams_adapter
        ActiveModelSerializers.config.adapter = :json_api
      end

    end
  end
end


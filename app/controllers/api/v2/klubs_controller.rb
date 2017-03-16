module Api
  module V2
    class KlubsController < ApplicationController

      before_action :select_ams_adapter

      def index

        render json: [] and return unless supported_categories.include? category_params

        stats = Klub.select('count(*) as count, max(updated_at) as last_update_at').completed.where("? = ANY (categories)", category_params).order(nil).first

        data = Rails.cache.fetch("v2/klubs/#{category_params}-#{stats.count}-#{stats.last_update_at.to_i}") do
          klubs = Klub.completed.where("? = ANY (categories)", category_params)
          serializer = ActiveModel::Serializer::CollectionSerializer.new(klubs, serializer: Api::V2::KlubListingSerializer)
          ActiveModelSerializers::Adapter.create(serializer).to_json
        end

        render json: data
      end

      def create
        klub = Klub.new(new_klub_params.except(:editor, :branches_attributes))
        klub.editor_emails << new_klub_params[:editor]

        head 403 and return unless klub.valid?

        # Create branches
        new_klub_params[:branches_attributes].each do |branch_attrs|
          branch = klub.created_branch branch_attrs
          head 403 and return unless branch
        end

        klub.save!

        klub.send_on_create_notifications new_klub_params[:editor]

        render json: klub, include: [:branches], status: :accepted
      end

      def update
        klub = find_klub

        updates = klub.create_updates update_klub_params.except(:branches_attributes)
        editor = update_klub_params[:editor]

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

        klub.send_on_update_notifications update_klub_params[:editor], updates, new_branches

        render json: 'null', status: :accepted
      end

      def show
        klub = find_klub
        render json: klub, include: [:branches, :parent]
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


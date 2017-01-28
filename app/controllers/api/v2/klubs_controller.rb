module Api
  module V2
    class KlubsController < ApplicationController

      before_action :select_ams_adapter

      def index
        stats = Klub.select('count(*) as count, max(updated_at) as last_update_at').completed.where("? = ANY (categories)", category_params).order(nil).first

        data = Rails.cache.fetch("v2/klubs/#{category_params}-#{stats.count}-#{stats.last_update_at.to_i}") do
          klubs = Klub.completed.where("? = ANY (categories)", category_params)
          serializer = ActiveModel::Serializer::CollectionSerializer.new(klubs, serializer: Api::V2::KlubListingSerializer)
          ActiveModelSerializers::Adapter.create(serializer).to_json
        end

        render json: data
      end

      def create
        @klub = Klub.new(new_klub_params.except(:editor))
        @klub.editor_emails << new_klub_params[:editor]
        @klub.save!
        @klub.send_review_notification
        @klub.send_thanks_notification new_klub_params[:editor] if new_klub_params[:editor]
        render nothing: true, status: :accepted

        # TODO: impelement error handling
        # https://blog.codeship.com/the-json-api-spec/
      end

      def update
        klub = Klub.completed.find_by(slug: params[:id])
        updates = klub.create_updates update_klub_params
        klub.send_updates_notification(updates)
        klub.send_confirm_notification(update_klub_params[:editor], updates) if update_klub_params[:editor]
        render nothing: true, status: :accepted
      end

      def show
        klub = Klub.completed.where(slug: params[:id]).first
        render json: klub
      end

    private

      def category_params
        params.require(:category)
      end

      def new_klub_params

        ActiveModelSerializers::Deserialization.jsonapi_parse!(params,
          only: [
            :name,
            :address,
            :town,
            :latitude,
            :longitude,
            :website,
            :'facebook-url',
            :phone,
            :email,
            :notes,
            :categories,
            :editor
          ]
        )
      end

      def update_klub_params
        ActiveModelSerializers::Deserialization.jsonapi_parse!(params,
          only: [
            :name,
            :address,
            :town,
            :latitude,
            :longitude,
            :website,
            :'facebook-url',
            :phone,
            :email,
            :notes,
            :categories,
            :editor
          ]
        )
      end

      def select_ams_adapter
        ActiveModelSerializers.config.adapter = :json_api # Default: `:attributes`
      end

    end
  end
end


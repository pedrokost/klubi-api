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
        @klub = Klub.new(new_klub_attributes.except('editor'))
        @klub.editor_emails << new_klub_attributes['editor']
        @klub.save!
        @klub.send_review_notification
        @klub.send_thanks_notification new_klub_attributes['editor'] if new_klub_attributes['editor']
        render nothing: true, status: :accepted

        # TODO: impelement error handling
        # https://blog.codeship.com/the-json-api-spec/
      end

      def update
        klub = Klub.completed.where(slug: params[:id]).first
        updates = klub.create_updates update_klub_attributes
        klub.send_updates_notification(updates)
        klub.send_confirm_notification(update_klub_attributes[:editor], updates) if update_klub_attributes[:editor]
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
        params.require(:data).permit(:type, {
          attributes: [
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
            {
              :categories => []
            },
            :editor]
        })
      end

      def new_klub_attributes
        new_klub_params[:attributes] || {}
      end

      def update_klub_params
        params.require(:data).permit(:type, :id, {
          attributes: [
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
            {
              :categories => []
            },
            :editor
          ]
        })
      end

      def update_klub_attributes
        update_klub_params[:attributes] || {}
      end

      def select_ams_adapter
        ActiveModelSerializers.config.adapter = :json_api # Default: `:attributes`
      end

    end
  end
end


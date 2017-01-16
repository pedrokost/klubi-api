module Api
  module V1
    class KlubsController < ApplicationController

      def index
        stats = Klub.select('count(*) as count, max(updated_at) as last_update_at').completed.where("? = ANY (categories)", category_param).order(nil).first

        data = Rails.cache.fetch("klubs/#{category_param}-#{stats.count}-#{stats.last_update_at.to_i}") do
          klubs = Klub.completed.where("? = ANY (categories)", category_param)
          serializer = ActiveModel::Serializer::CollectionSerializer.new(klubs)
          ActiveModelSerializers::Adapter.create(serializer).to_json
        end

        render json: data
      end

      def create
        @klub = Klub.new(new_klub_param.except('editor'))
        @klub.editor_emails << new_klub_param['editor']
        @klub.save!
        @klub.send_review_notification
        @klub.send_thanks_notification new_klub_param['editor'] if new_klub_param['editor']
        render nothing: true
      end

      def update
        klub = Klub.completed.where(slug: params[:id]).first
        updates = klub.create_updates update_klub_param
        klub.send_updates_notification(updates)
        klub.send_confirm_notification(update_klub_param[:editor], updates) if update_klub_param[:editor]
        render nothing: true, status: :accepted
      end

      def find_by_slug
        klub = Klub.completed.where(slug: params[:slug]).first
        render json: klub
      end

    private

      def category_param
        params.require(:category)
      end

      def new_klub_param
        params.require(:klub).permit(:name, :address, :town, :latitude, :longitude, :website, :facebook_url, :phone, :email, :notes, {:categories => []}, :editor)
      end

      def update_klub_param
        params.require(:klub).permit(:name, :address, :town, :latitude, :longitude, :website, :facebook_url, :phone, :email, :notes, {:categories => []}, :editor)
      end

    end
  end
end


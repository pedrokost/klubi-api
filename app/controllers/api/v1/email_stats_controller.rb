require 'openssl'

module Api
  module V1
    class EmailStatsController < ApplicationController

      def webhook
        verified = verify_authenticity(ENV['MAILGUN_API_KEY'],
          mailgun_params[:token],
          mailgun_params[:timestamp],
          mailgun_params[:signature])

        if !verified
          render nothing: true, status: :not_acceptable
          return
        end

        begin
          EmailStat.transaction do
            stat = EmailStat.find_or_create_by(email: mailgun_params[:recipient])

            method_field = "last_#{mailgun_params[:event]}_at="
            stat.send(method_field, Time.at(mailgun_params[:timestamp].to_i).utc)

            stat.save!

          end
        rescue NoMethodError => e
          logger.info "Received unsupported event type from Mailgun: #{mailgun_params[:event]}"

          render nothing: true, status: :not_acceptable
          return
        end

        render nothing: true, status: :ok
      end

    private

      def verify_authenticity(api_key, token, timestamp, signature)
        digest = OpenSSL::Digest::SHA256.new
        data = [timestamp, token].join
        signature == OpenSSL::HMAC.hexdigest(digest, api_key, data)
      end

      def mailgun_params
        params.require(:recipient)
        params.require(:event)
        params.require(:timestamp)
        params.require(:token)
        params.require(:signature)

        params.permit(:recipient, :event, :timestamp, :token, :signature, :domain)
      end
    end
  end
end

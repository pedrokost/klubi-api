Koala.configure do |config|
  config.app_id = Rails.application.credentials.FB_APP_ID
  config.app_secret = Rails.application.credentials.FB_APP_SECRET
  # See Koala::Configuration for more options, including details on how to send requests through
  # your own proxy servers.
end

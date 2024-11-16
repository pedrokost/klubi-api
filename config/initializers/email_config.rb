ActionMailer::Base.smtp_settings = {
  :address => Rails.application.credentials.EMAIL_ADDRESS,
  :port => Rails.application.credentials.EMAIL_PORT,
  :domain => Rails.application.credentials.EMAIL_DOMAIN,
  :authentication => :login,
  :user_name => Rails.application.credentials.EMAIL_USERNAME,
  :password => Rails.application.credentials.EMAIL_PASSWORD,
  :enable_starttls_auto => true
}

# ActionMailer::Base.default_content_type = "text/html"
ActionMailer::Base.raise_delivery_errors = true

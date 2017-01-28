ActionMailer::Base.smtp_settings = {
  :address => ENV["EMAIL_ADDRESS"],
  :port => ENV["EMAIL_PORT"],
  :domain => ENV["EMAIL_DOMAIN"],
  :authentication => :login,
  :user_name => ENV['EMAIL_USERNAME'],
  :password => ENV['EMAIL_PASSWORD'],
  :enable_starttls_auto => true
}

# ActionMailer::Base.default_content_type = "text/html"
ActionMailer::Base.raise_delivery_errors = true

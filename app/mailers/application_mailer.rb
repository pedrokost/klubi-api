class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.DEFAULT_EMAIL
  helper EmailHelper
end

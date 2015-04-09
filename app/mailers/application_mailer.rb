class ApplicationMailer < ActionMailer::Base
  default from: ENV['DEFAULT_EMAIL']
end

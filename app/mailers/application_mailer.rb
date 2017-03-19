class ApplicationMailer < ActionMailer::Base
  default from: ENV['DEFAULT_EMAIL']
  add_template_helper(EmailHelper)
end

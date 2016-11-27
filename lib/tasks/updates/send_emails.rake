#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2016-11-20 11:49:44
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2016-11-20 11:49:47
# require 'update_accepted_mailer'

namespace :updates do
  desc "Send email to editors for accepted updates"
  task :send_emails => :environment do
    puts "Sending emails for accepted updates"
    UpdateAcceptedMailer.send_emails
    puts "Finished sending emails for accepted updates"
  end
end

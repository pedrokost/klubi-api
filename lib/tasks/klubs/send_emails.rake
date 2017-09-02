
namespace :klubs do
  desc "Send email to request klub data verification"
  task :send_emails => :environment do

    puts "Sending emails for verifying data"
    SendDataVerificationEmails.new.call
    puts "Finished sending emails for verifying data"
  end
end

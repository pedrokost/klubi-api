#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-01-07 21:23:02
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2018-02-11 13:39:01

class SendDataVerificationEmails
  # Sends email to klub owners who have not verified their klub data for a
  # while

  def call
    klubs_to_email = awaiting_klubs

    msg = "Will send #{klubs_to_email.count} emails for data verification"
    Rails.logger.info msg
    puts msg

    klubs_to_email.each do |klub|
      msg = "Sending data verification request email to #{klub.email} for klub #{klub.name}"
      Rails.logger.info msg
      puts msg

      klub.update_visits_count_if_outdated!
      klub.branches.each(&:update_visits_count_if_outdated!)

      klub.send_request_verify_klub_data_mail
    end
  rescue Exception => e
    Rails.logger.error e
    puts e
    Raygun.track_exception(e)
  end
  def awaiting_klubs
    doorman = OutgoingEmailDoorman.new(Rails.application.credentials.EXPECTED_NUM_DAILY_DATA_VERIFICATION_EMAILS.to_i, Rails.application.credentials.WANTED_OUTGOING_EMAIL_DISTRIBTION.split(',').map(&:to_f))

    send_num_emails = doorman.number_of_emails_to_send_now

    # Ordered list of klubs to receive the the notification
    threshold_date = Rails.application.credentials.REQUIRE_NEW_VERIFICATION_AFTER.to_i.days.ago
    supported_categories = Rails.application.credentials.SUPPORTED_CATEGORIES.split ','

    Klub.where('last_verification_reminder_at IS NULL OR last_verification_reminder_at < ?', threshold_date)
        .where('data_confirmed_at IS NULL OR data_confirmed_at < ?', threshold_date) # TODO:test
        .where(verified: true)
        .where('ARRAY[?]::varchar[] && categories', supported_categories)
        .where(parent: nil)
        .where('email LIKE ?', '%@%')
        .where(closed_at: nil)
        .order('last_verification_reminder_at ASC NULLS FIRST, created_at ASC')
        .limit(send_num_emails)
  end
end

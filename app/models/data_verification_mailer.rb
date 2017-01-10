#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-01-07 21:23:02
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-01-10 22:33:09

class DataVerificationMailer
  # Sends email to klub owners who have not verified their klub data for a
  # while

  def self.awaiting_klubs
    # Ordered list of klubs to receive the the notification
    threshold_date = ENV['REQUIRE_NEW_VERIFICATION_AFTER'].to_i.days.ago
    supported_categories = ENV['SUPPORTED_CATEGORIES'].split ','

    Klub.where('last_verification_reminder_at IS NULL OR last_verification_reminder_at < ?', threshold_date)
      .where(verified: true)
      .where('ARRAY[?]::varchar[] && categories', supported_categories)
      .where.not(email: nil)
      .order('last_verification_reminder_at ASC NULLS FIRST')
      .limit(ENV['NUM_DAILY_DATA_VERIFICATION_EMAILS'])
  end

  def self.send_emails
    self.awaiting_klubs.each do |klub|
      klub.send_request_verify_klub_data_mail
    end
  end
end

#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-07-22 20:39:50
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-08-04 23:27:30

class OutgoingEmailDoorman
  # This class helps you determine how many emails to send each hour it
  # is called.
  # Assumptions: make sure to only call this class exactly once per hour
  # or you will send too many emails!

  attr_reader :emails_to_send_today, :hourly_distribution

  def initialize(num_daily_emails, hourly_distribution)
    raise ArgumentError.new('Not a valid hourly distribution') unless hourly_distribution.length == 24
    raise ArgumentError.new('Not a valid hourly distribution') unless (1 - hourly_distribution.sum).abs < 0.0001

    @emails_to_send_today = num_daily_emails
    @hourly_distribution = hourly_distribution
  end

  def number_of_emails_to_send_now
    current_hour = Time.now.utc.hour
    expect_emails_to_send_now = hourly_distribution[current_hour] * emails_to_send_today

    to_send = expect_emails_to_send_now.floor
    to_send += rand <= (expect_emails_to_send_now - to_send) ? 1 : 0
  end
end

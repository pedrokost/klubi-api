#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-07-22 20:39:50
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-08-19 22:12:42

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

  def sending_probability
    # Combines the hourly sending distributions with the success rate of
    # past emails.
    current_hour = Time.now.utc.hour
    hourly_distribution[current_hour] * email_success_score
  end

  def number_of_emails_to_send_now
    current_hour = Time.now.utc.hour

    expect_emails_to_send_now = sending_probability * emails_to_send_today

    to_send = expect_emails_to_send_now.floor
    to_send += rand <= (expect_emails_to_send_now - to_send) ? 1 : 0
  end

private

  def email_success_score
    # The success rate of past emails is computed such that it quickly drops
    # on a dropped delivery, and then slowly recovers.
    # For each day up to `days_ago` we compute the success rate of sending emails
    # which are weighted by signficance. Then for each past day we divide the
    # score by the age (in days). Finally we sum it all together and divide
    # by the maximum possible value to arrive at a probability. This probability
    # is then used to multiply the hourly distribution for the current hour.
    # Why? Because I send emails using MailChimp which can be penalized by other
    # bad players and temporarily marked as spam

    days_ago = 4
    delivered_weight = 1.0
    bounced_weight = 1.0
    dropped_weight = 2.0

    # Performance optimization (for tests mostly)
    if EmailStat.where('updated_at > ?', Time.now - days_ago.days).count == 0
      return 1.0
    end

    history_delivered = EmailStat.where.not(last_delivered_at: nil).where('last_delivered_at >= ?', Time.now - days_ago.days).group("now()::date - last_delivered_at::date").count
    history_bounced = EmailStat.where.not(last_bounced_at: nil).where('last_bounced_at >= ?', Time.now - days_ago.days).group("now()::date - last_bounced_at::date").count
    history_dropped = EmailStat.where.not(last_dropped_at: nil).where('last_dropped_at >= ?', Time.now - days_ago.days).group("now()::date - last_dropped_at::date").count

    success_score = [ [0.01] * (days_ago + 1), [0.01] * (days_ago + 1) ]

    history_delivered.each do |age, count|
      success_score[0][age] += count * delivered_weight
    end
    history_bounced.each do |age, count|
      success_score[1][age] += count * bounced_weight
    end
    history_dropped.each do |age, count|
      success_score[1][age] += count * dropped_weight
    end

    day_score = [0] * (days_ago + 1)

    (days_ago + 1).times do |i|
      day_score[i] = success_score[0][i] / (success_score[1][i] + success_score[0][i])
    end

    max_series_sum = (1..(days_ago + 1)).map { |x| 1.0/x }.sum

    final_score = day_score.each.with_index.inject(0) do |sum, (value, index)|
      sum + value / (index + 1)
    end / max_series_sum

    final_score
  end
end

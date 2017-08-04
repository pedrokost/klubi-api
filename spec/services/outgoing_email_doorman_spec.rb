#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-07-22 20:43:06
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-08-05 11:28:11

require 'rails_helper'

RSpec.describe OutgoingEmailDoorman do
  include ActiveSupport::Testing::TimeHelpers

  it "should throw error if not valid distribution" do
    expect { OutgoingEmailDoorman.new(1, [1.0/26] * 24) }.to raise_error(ArgumentError, "Not a valid hourly distribution")
  end

  it "should throw if hourly distributions does not cover day" do
    expect { OutgoingEmailDoorman.new(1, [1.0/26] * 26) }.to raise_error(ArgumentError, "Not a valid hourly distribution")
  end

  def hourly_average_emails num_daily_emails, hourly_distribution
    num_days = 25
    doorman = OutgoingEmailDoorman.new(num_daily_emails, hourly_distribution)

    travel_to Time.utc(2017, 11, 24, 00, 15, 00)

    total_emails_sent_per_hour = [0] * 24
    num_days.times do
      24.times do |hour|
        emails_to_send = doorman.number_of_emails_to_send_now
        total_emails_sent_per_hour[hour] += emails_to_send
        travel 1.hour
      end
    end
    travel_back

    avg_emails_sent_per_hour = total_emails_sent_per_hour.map{ |e| e.to_f / num_days }
  end

  def daily_average_emails num_daily_emailss, hourly_distribution
    avg_hourly_emails = hourly_average_emails num_daily_emails, hourly_distribution
    avg_hourly_emails.sum
  end

  describe "an email each hour" do
    let(:hourly_distribution) { [1.0/24] * 24 }
    let(:num_daily_emails) { 24 }

    it "should send 24 emails a day on average" do
      total_emails_sent = daily_average_emails num_daily_emails, hourly_distribution
      expect( (total_emails_sent - num_daily_emails).abs).to be < num_daily_emails * 0.1
    end

    it "should send 1 email per hour on average" do
      avg_emails_sent_per_hour = hourly_average_emails num_daily_emails, hourly_distribution

      avg_emails_expected_per_hour = hourly_distribution.map { |e| e * num_daily_emails }
      expect_vs_actual = avg_emails_sent_per_hour.zip(avg_emails_expected_per_hour).map { |x, y| (y - x).abs }

      expect(expect_vs_actual).to all( be <= 0.1 * num_daily_emails / 24  )
    end
  end

  describe "few emails a day" do
    let(:num_daily_emails) { 7 }
    let(:hourly_distribution) {
      counts = [0] * 6 + [1] * 12 + [0] * 6
      counts.collect { |n| n / 12.0 }
    }

    it "should send 7 emails a day on average" do
      total_emails_sent = daily_average_emails num_daily_emails, hourly_distribution
      expect( (total_emails_sent - num_daily_emails).abs).to be < num_daily_emails * 0.1
    end

    it "should send emails according to distribution" do
      avg_emails_sent_per_hour = hourly_average_emails num_daily_emails, hourly_distribution

      avg_emails_expected_per_hour = hourly_distribution.map { |e| e * num_daily_emails }
      expect_vs_actual = avg_emails_sent_per_hour.zip(avg_emails_expected_per_hour).map { |x, y| (y - x).abs }

      expect(expect_vs_actual).to all( be <= 0.3  )
    end
  end

  describe "several emails each hour" do
    let(:hourly_distribution) {
      counts = [0] * 6 + [2] * 3 + [1] * 6 + [2] * 3 + [0] * 6
      counts_sum = counts.sum.to_f
      counts.collect { |n| n / counts_sum }
    }
    let(:num_daily_emails) { 180 }

    it "should send 180 emails a day on average" do
      total_emails_sent = daily_average_emails num_daily_emails, hourly_distribution
      expect( (total_emails_sent - num_daily_emails).abs).to be < num_daily_emails * 0.1
    end

    it "should send emails according to distribution" do
      avg_emails_sent_per_hour = hourly_average_emails num_daily_emails, hourly_distribution

      avg_emails_expected_per_hour = hourly_distribution.map { |e| e * num_daily_emails }
      expect_vs_actual = avg_emails_sent_per_hour.zip(avg_emails_expected_per_hour).map { |x, y| (y - x).abs }

      expect(expect_vs_actual).to all( be <= 0.1 * num_daily_emails / 24  )
    end
  end
end

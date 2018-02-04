#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2016-11-27 15:42:50
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2018-02-04 20:40:26


require 'rails_helper'

RSpec.describe SendDataVerificationEmails do

  subject { SendDataVerificationEmails.new }

  let!(:klub1) { create(:complete_klub, email: 'test@test.com', last_verification_reminder_at: DateTime.now ) }
  let!(:klub2) { create(:complete_klub, email: 'test@test.com', last_verification_reminder_at: 1.year.ago ) }
  let!(:klub3) { create(:complete_klub, email: 'test@test.com') }
  let!(:klub4) { create(:complete_klub, email: 'test@test.com') }
  let!(:closed_klub) { create(:complete_klub, email: 'closed@test.com', closed_at: Date.yesterday) }
  let!(:klub_nil_email) { create(:complete_klub, email: nil) }
  let!(:klub_invalid_email) { create(:complete_klub, email: '234 234 234') }
  let!(:klub_blank_email) { create(:complete_klub, email: '') }
  let!(:unverified_klub) { create(:complete_klub, email: 'test@test.com', verified: false) }
  let!(:unsupported_category_klub) { create(:complete_klub, email: 'test@test.com', categories: ['pentafloss']) }
  let!(:klub_branch) { create(:complete_klub, email: 'test@test.com', parent: klub4) }


  describe "awaiting_klubs" do
    before do
      allow(ENV).to receive(:[]).with("REQUIRE_NEW_VERIFICATION_AFTER").and_return(180)
      allow(ENV).to receive(:[]).with("SUPPORTED_CATEGORIES").and_return('fitnes,wellness,karate,frizbi,judo,gimnastika,cheerleading')

      allow(ENV).to receive(:[]).with("EXPECTED_NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return("24")
      allow(ENV).to receive(:[]).with("WANTED_OUTGOING_EMAIL_DISTRIBTION").and_return ([1.0/24] * 24).join(',')
    end

    it "should not include klubs to which a notif was recently sent" do
      expect_any_instance_of(OutgoingEmailDoorman).to receive(:number_of_emails_to_send_now).and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(klub1.id)
    end

    it "should not include klubs which are not verified" do
      expect_any_instance_of(OutgoingEmailDoorman).to receive(:number_of_emails_to_send_now).and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(unverified_klub.id)
    end

    it "should not include klubs which are closed" do
      expect_any_instance_of(OutgoingEmailDoorman).to receive(:number_of_emails_to_send_now).and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(closed_klub.id)
    end

    it "should not send emails for klub of unsupported categories" do
      expect_any_instance_of(OutgoingEmailDoorman).to receive(:number_of_emails_to_send_now).and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(unsupported_category_klub.id)
    end

    it "should include klubs to which not notif was sent" do
      expect_any_instance_of(OutgoingEmailDoorman).to receive(:number_of_emails_to_send_now).and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).to include(klub3.id, klub4.id)
    end

    it "should filter out branches" do
      expect_any_instance_of(OutgoingEmailDoorman).to receive(:number_of_emails_to_send_now).and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(klub_branch.id)
    end

    it "should include klubs to which a notif was sent long ago" do
      expect_any_instance_of(OutgoingEmailDoorman).to receive(:number_of_emails_to_send_now).and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).to include(klub2.id)
    end

    it "should order the list" do
      expect_any_instance_of(OutgoingEmailDoorman).to receive(:number_of_emails_to_send_now).and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).to match([klub3.id, klub4.id, klub2.id])
    end

    it "should limit the number of daily emails using the doorman" do
      expect_any_instance_of(OutgoingEmailDoorman).to receive(:number_of_emails_to_send_now).and_return(2)

      expect(subject.awaiting_klubs.map(&:id)).to match_array([klub3.id, klub4.id])
    end

    it "should filter out klubs with nil emails" do
      expect_any_instance_of(OutgoingEmailDoorman).to receive(:number_of_emails_to_send_now).and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(klub_nil_email.id)
    end

    it "should filter out klubs with invalid emails" do
      expect_any_instance_of(OutgoingEmailDoorman).to receive(:number_of_emails_to_send_now).and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(klub_invalid_email.id)
    end

    it "should filter out klubs with blank emails" do
      expect_any_instance_of(OutgoingEmailDoorman).to receive(:number_of_emails_to_send_now).and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(klub_blank_email.id)
    end
  end

  it "should send the emails" do
    allow(subject).to receive(:awaiting_klubs).and_return([klub4])
    allow(klub4).to receive(:branches).and_return([])
    allow(klub4).to receive(:update_visits_count_if_outdated!).exactly(2).times

    expect(klub4).to receive(:send_request_verify_klub_data_mail)

    subject.call
  end

  it "should update the visits count" do
    allow(subject).to receive(:awaiting_klubs).and_return([klub4])
    allow(klub4).to receive(:branches).and_return([klub_branch])
    allow(klub4).to receive(:send_request_verify_klub_data_mail)

    expect(klub4).to receive(:update_visits_count_if_outdated!)
    expect(klub_branch).to receive(:update_visits_count_if_outdated!)

    subject.call
  end
end

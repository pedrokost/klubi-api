#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2016-11-27 15:42:50
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-05-14 17:04:20


require 'rails_helper'

RSpec.describe SendDataVerificationEmails do

  subject { SendDataVerificationEmails.new }

  let!(:klub1) { create(:complete_klub, email: 'test@test.com', last_verification_reminder_at: DateTime.now ) }
  let!(:klub2) { create(:complete_klub, email: 'test@test.com', last_verification_reminder_at: 1.year.ago ) }
  let!(:klub3) { create(:complete_klub, email: 'test@test.com') }
  let!(:klub4) { create(:complete_klub, email: 'test@test.com') }
  let!(:closed_klub) { create(:complete_klub, email: 'closed@test.com', closed_at: Date.yesterday) }
  let!(:klub_nil_email) { create(:complete_klub, email: nil) }
  let!(:klub_blank_email) { create(:complete_klub, email: '') }
  let!(:unverified_klub) { create(:complete_klub, email: 'test@test.com', verified: false) }
  let!(:unsupported_category_klub) { create(:complete_klub, email: 'test@test.com', categories: ['pentafloss']) }
  let!(:klub_branch) { create(:complete_klub, email: 'test@test.com', parent: klub4) }


  describe "awaiting_klubs" do
    before do
      allow(ENV).to receive(:[]).with("REQUIRE_NEW_VERIFICATION_AFTER").and_return(180)
      allow(ENV).to receive(:[]).with("SUPPORTED_CATEGORIES").and_return('fitnes,wellness,karate,frizbi,judo,gimnastika,cheerleading')
    end

    it "should not include klubs to which a notif was recently sent" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(klub1.id)
    end

    it "should not include klubs which are not verified" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(unverified_klub.id)
    end

    it "should not include klubs which are closed" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(closed_klub.id)
    end

    it "should not send emails for klub of unsupported categories" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(unsupported_category_klub.id)
    end

    it "should include klubs to which not notif was sent" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).to include(klub3.id, klub4.id)
    end

    it "should filter out branches" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(klub_branch.id)
    end

    it "should include klubs to which a notif was sent long ago" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).to include(klub2.id)
    end

    it "should order the list" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).to match([klub3.id, klub4.id, klub2.id])
    end

    it "should limit the number of daily emails" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(2)
      expect(subject.awaiting_klubs.map(&:id)).to match_array([klub3.id, klub4.id])
    end

    it "should filter out klubs with nil emails" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(klub_nil_email)
    end

    it "should filter out klubs with blank emails" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(subject.awaiting_klubs.map(&:id)).not_to include(klub_blank_email)
    end
  end

  it "should send the emails" do
    allow(subject).to receive(:awaiting_klubs).and_return([klub4])

    expect_any_instance_of(Klub).to receive(:send_request_verify_klub_data_mail)

    subject.call
  end
end

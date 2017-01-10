#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2016-11-27 15:42:50
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-01-10 22:28:40


require 'rails_helper'

RSpec.describe DataVerificationMailer, type: :model do

  let!(:klub1) { create(:complete_klub, email: 'test@test.com', last_verification_reminder_at: DateTime.now ) }
  let!(:klub2) { create(:complete_klub, email: 'test@test.com', last_verification_reminder_at: 1.year.ago ) }
  let!(:klub3) { create(:complete_klub, email: 'test@test.com') }
  let!(:klub4) { create(:complete_klub, email: 'test@test.com') }
  let!(:klub5) { create(:complete_klub, email: nil) }
  let!(:unverified_klub) { create(:complete_klub, email: 'test@test.com', verified: false) }
  let!(:unsupported_category_klub) { create(:complete_klub, email: 'test@test.com', categories: ['pentafloss']) }


  describe "self.awaiting_klubs" do
    before do
      allow(ENV).to receive(:[]).with("REQUIRE_NEW_VERIFICATION_AFTER").and_return(180)
      allow(ENV).to receive(:[]).with("SUPPORTED_CATEGORIES").and_return('fitnes,wellness,karate,frizbi,judo,gimnastika,cheerleading')
    end

    it "should not include klubs to which a notif was recently sent" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(DataVerificationMailer.awaiting_klubs.map(&:id)).not_to include(klub1.id)
    end

    it "should not include klubs which are not verified" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(DataVerificationMailer.awaiting_klubs.map(&:id)).not_to include(unverified_klub.id)
    end

    it "should not send emails for klub of unsupported categories" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(DataVerificationMailer.awaiting_klubs.map(&:id)).not_to include(unsupported_category_klub.id)
    end

    it "should include klubs to which not notif was sent" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(DataVerificationMailer.awaiting_klubs.map(&:id)).to include(klub3.id, klub4.id)
    end

    it "should include klubs to which a notif was sent long ago" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(DataVerificationMailer.awaiting_klubs.map(&:id)).to include(klub2.id)
    end

    it "should order the list" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(100)
      expect(DataVerificationMailer.awaiting_klubs.map(&:id)).to match([klub3.id, klub4.id, klub2.id])
    end

    it "should limit the number of daily emails" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(2)
      expect(DataVerificationMailer.awaiting_klubs.map(&:id)).to match([klub3.id, klub4.id])
    end

    it "should only filter klubs with emails" do
      allow(ENV).to receive(:[]).with("NUM_DAILY_DATA_VERIFICATION_EMAILS").and_return(2)
      expect(DataVerificationMailer.awaiting_klubs.map(&:id)).to match([klub3.id, klub4.id])
    end
  end

  describe "self.send_emails" do

    it "should send the emails" do
      allow(DataVerificationMailer).to receive(:awaiting_klubs).and_return([klub4])

      expect_any_instance_of(Klub).to receive(:send_request_verify_klub_data_mail)

      DataVerificationMailer.send_emails
    end
  end

  # describe "self.send_email" do
  #   it "should send an email" do
  #     expect(klub2).to receive(:send_updates_accepted_notification).with('another@editor.com', [update4, update5])

  #     args = ['another@editor.com', klub2, [update4, update5]]
  #     DataVerificationMailer.send_email(*args)
  #   end

  #   it "should mark the updates as emails-sent" do
  #     args = ['another@editor.com', klub2, [update4, update5]]
  #     expect { DataVerificationMailer.send_email(*args) }.to change( Update.should_notify, :count ).by(-2)
  #   end
  # end
end

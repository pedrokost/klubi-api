#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2016-11-27 15:42:50
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-01-29 10:55:07


require 'rails_helper'

RSpec.describe SendUpdateAcceptedEmails do

  subject { SendUpdateAcceptedEmails.new }

  let(:klub1) { create(:klub, categories: ['karate']) }
  let(:klub2) { create(:klub, categories: ['karate']) }

  let!(:update1) { create(:update, updatable: klub1, status: :accepted, field: 'name', newvalue: 'Pear', editor_email: 'first@editor.com', acceptance_email_sent: false) }
  let!(:update2) { create(:update, updatable: klub1, status: :unverified, field: 'address', newvalue: 'The address', editor_email: 'first@editor.com', acceptance_email_sent: false) }

  let!(:update3) { create(:update, updatable: klub1, status: :accepted, field: 'name', newvalue: 'Pear', editor_email: 'another@editor.com', acceptance_email_sent: false) }

  let!(:update4) { create(:update, updatable: klub2, status: :accepted, field: 'address', newvalue: 'The address', editor_email: 'another@editor.com', acceptance_email_sent: false) }
  let!(:update5) { create(:update, updatable: klub2, status: :accepted, field: 'phone', newvalue: '0123', editor_email: 'another@editor.com', acceptance_email_sent: false) }

  describe "groups" do
    it "should yield control 3 times" do
      expect{ |b| subject.groups(&b) }.to yield_control.exactly(3).times
    end

    it "should yield with appropriate data" do
      expect { |b| subject.groups(&b) }.to yield_successive_args(
        ['first@editor.com', klub1, [update1]],
        ['another@editor.com', klub1, [update3]],
        ['another@editor.com', klub2, [update4, update5]],
      )
    end
  end

  it "should call send_email for each group" do
    expect(subject).to receive(:send_email).exactly(3).times.with(String, Klub, Array)

    subject.call
  end

  describe "send_email" do
    it "should send an email" do
      expect(klub2).to receive(:send_updates_accepted_notification).with('another@editor.com', [update4, update5])

      args = ['another@editor.com', klub2, [update4, update5]]
      subject.send_email(*args)
    end

    it "should mark the updates as emails-sent" do
      args = ['another@editor.com', klub2, [update4, update5]]
      expect { subject.send_email(*args) }.to change( Update.should_notify, :count ).by(-2)
    end
  end
end

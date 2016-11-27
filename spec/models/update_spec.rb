require 'rails_helper'

RSpec.describe Update, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  let!(:klub) { create(:klub) }
  let(:update) { create(:update, updatable: klub, status: :unverified, field: 'name', newvalue: 'Pear') }

  subject { update }

  describe "resolve!" do
    it "should just set the status when accepted" do
      update.status = :accepted
      expect { update.resolve! }.to change(klub, :name)
    end
  end

  describe "self.should_notify" do
    it "should only include accepted clubs" do
      expect {
        create(:update, updatable: klub, status: :accepted, acceptance_email_sent: false)
       }.to change{Update.should_notify.count}.by(1)
    end

    it "should only contain clubs updates which were not already notified" do
      expect {
        create(:update, updatable: klub, status: :accepted, acceptance_email_sent: true)
       }.not_to change{Update.should_notify.count}
    end

  end
end

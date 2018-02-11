require 'rails_helper'

RSpec.describe Update, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  let!(:klub) { create(:klub, categories: ['running']) }
  let(:update) { create(:update, updatable: klub, status: :unverified, field: 'name', newvalue: 'Pear', created_at: 5.days.ago.beginning_of_day ) }

  let(:category_update) { create(:update, updatable: klub, status: :accepted, field: 'categories', newvalue: ['swimming', 'dance']) }

  subject { update }

  describe "resolve!" do
    it "should just set the status when accepted" do
      update.status = :accepted
      expect { update.resolve! }.to change(klub, :name)
    end

    it "should correctly update the categories" do
      category_update.resolve!
      expect( klub.reload.categories ).to match(['swimming', 'dance'])
    end

    it "should remove duplicates form categories" do
      category_update.newvalue = ['swimming', 'dance', 'dance', 'swimming']
      category_update.resolve!
      expect( klub.reload.categories ).to match(['swimming', 'dance'])
    end

    it "should dasherize categories" do
      category_update.newvalue = ['jazz dance', 'judo magic']
      category_update.resolve!
      expect( klub.reload.categories ).to match(['jazz-dance', 'judo-magic'])
    end

    it "shoud delete updatable if accepting a marked-for-deletion" do
      update.field = "marked_for_deletion"
      update.status = :accepted
      expect { update.resolve! }.to change(Klub, :count).by(-1)
    end

    it "should set the data_confirmed_at" do
      update.status = :accepted
      expect { update.resolve! }.to change(klub, :data_confirmed_at)
      expect( klub.reload.data_confirmed_at ).to eq update.created_at
    end

    it "should keep data_confirmed_at if accepting old update" do
      klub.data_confirmed_at = 3.days.ago
      klub.save!
      update.status = :accepted
      expect { update.resolve! }.not_to change(klub, :data_confirmed_at)
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

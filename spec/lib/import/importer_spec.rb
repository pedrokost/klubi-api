require 'rails_helper'
require 'import/importer'
require 'import/datasource'
require 'import/transformer'

require 'pry'

RSpec.describe Import::Importer do

  let(:datasource) { instance_double(Import::Datasource) }
  let(:transformer) { instance_double(Import::Transformer) }

  subject { Import::Importer.new(datasource, transformer, false) }

  before do
    data = [
      {
        name: 'Fitnes 1',
        categories: ['fitnes']
      },
      {
        name: 'Fitnes 2',
        categories: ['fitnes']
      }
    ]
    allow(datasource).to receive(:fetch).and_return data
    allow(transformer).to receive(:description).and_return('abracadabra')
    allow(transformer).to receive(:transform).and_return data
  end

  # Pubic methods
  it { is_expected.to respond_to :run }

  # Private methods
  it { is_expected.not_to respond_to :commit }
  it { is_expected.not_to respond_to :commit_one }

  it "should be able to commit an array of klubs data" do
    expect{subject.run}.to change{Klub.unscoped.count}.by 2
  end

  describe "it add not add duplicate klubs" do
    before do
      subject.run
    end

    it "should not add if same name" do
      expect(Klub.unscoped.count).to eq 2

      expect { subject.run }.not_to change{Klub.unscoped.count}
    end

    it "should prompt for resolution if different address, same name"

    it "should not add duplicates - case insensitive" do
      data = [
        {
          name: 'FitNes 1'
        }
      ]
      allow(transformer).to receive(:transform).and_return data

      expect { subject.run }.not_to change{Klub.unscoped.count}
    end
  end

  describe "it should update club category" do
    before do
      subject.run
    end

    it "should amend the category to a duplicate club" do
      data = [
        {
          name: 'Fitnes 1',
          categories: ['pilates']
        }
      ]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.categories ).to match ['fitnes']
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.categories ).to match ['fitnes', 'pilates']
    end

    it "should ammend the address if missing" do
      data = [{
              name: 'Fitnes 1',
              address: 'Trzaska 25, 1000 Ljubljana'
            }]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.address ).to be_nil
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.address ).to eq 'Trzaska 25, 1000 Ljubljana'
    end

    it "should not amend the address if not missing" do
      klub = Klub.unscoped.where(name: 'Fitnes 1').first
      klub.address = 'Nekje 22'
      klub.save!

      data = [{
              name: 'Fitnes 1',
              address: 'Trzaska 25, 1000 Ljubljana'
            }]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.address ).to eq 'Nekje 22'
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.address ).to eq 'Nekje 22'
    end

    it "should ammend the facebook_url if missing" do
      data = [{
              name: 'Fitnes 1',
              facebook_url: 'Trzaska 25, 1000 Ljubljana'
            }]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.facebook_url ).to be_nil
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.facebook_url ).to eq 'Trzaska 25, 1000 Ljubljana'
    end

    it "should not amend the facebook_url if not missing" do
      klub = Klub.unscoped.where(name: 'Fitnes 1').first
      klub.facebook_url = 'Nekje 22'
      klub.save!

      data = [{
              name: 'Fitnes 1',
              facebook_url: 'Trzaska 25, 1000 Ljubljana'
            }]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.facebook_url ).to eq 'Nekje 22'
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.facebook_url ).to eq 'Nekje 22'
    end

    it "should ammend the website if missing" do
      data = [{
              name: 'Fitnes 1',
              website: 'Trzaska 25, 1000 Ljubljana'
            }]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.website ).to be_nil
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.website ).to eq 'Trzaska 25, 1000 Ljubljana'
    end

    it "should not amend the website if not missing" do
      klub = Klub.unscoped.where(name: 'Fitnes 1').first
      klub.website = 'Nekje 22'
      klub.save!

      data = [{
              name: 'Fitnes 1',
              website: 'Trzaska 25, 1000 Ljubljana'
            }]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.website ).to eq 'Nekje 22'
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.website ).to eq 'Nekje 22'
    end

    it "should ammend the town if missing" do
      data = [{
              name: 'Fitnes 1',
              town: 'Trzaska 25, 1000 Ljubljana'
            }]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.town ).to be_nil
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.town ).to eq 'Trzaska 25, 1000 Ljubljana'
    end

    it "should not amend the town if not missing" do
      klub = Klub.unscoped.where(name: 'Fitnes 1').first
      klub.town = 'Nekje 22'
      klub.save!

      data = [{
              name: 'Fitnes 1',
              town: 'Trzaska 25, 1000 Ljubljana'
            }]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.town ).to eq 'Nekje 22'
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.town ).to eq 'Nekje 22'
    end

    it "should ammend the phone if missing" do
      data = [{
              name: 'Fitnes 1',
              phone: 'Trzaska 25, 1000 Ljubljana'
            }]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.phone ).to be_nil
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.phone ).to eq 'Trzaska 25, 1000 Ljubljana'
    end

    it "should not amend the phone if not missing" do
      klub = Klub.unscoped.where(name: 'Fitnes 1').first
      klub.phone = 'Nekje 22'
      klub.save!

      data = [{
              name: 'Fitnes 1',
              phone: 'Trzaska 25, 1000 Ljubljana'
            }]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.phone ).to eq 'Nekje 22'
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.phone ).to eq 'Nekje 22'
    end

    it "should ammend the email if missing" do
      data = [{
              name: 'Fitnes 1',
              email: 'Trzaska 25, 1000 Ljubljana'
            }]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.email ).to be_nil
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.email ).to eq 'Trzaska 25, 1000 Ljubljana'
    end

    it "should not amend the email if not missing" do
      klub = Klub.unscoped.where(name: 'Fitnes 1').first
      klub.email = 'Nekje 22'
      klub.save!

      data = [{
              name: 'Fitnes 1',
              email: 'Trzaska 25, 1000 Ljubljana'
            }]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.email ).to eq 'Nekje 22'
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.email ).to eq 'Nekje 22'
    end

    it "should not add duplicate categories" do
      data = [
        {
          name: 'Fitnes 1',
          categories: ['pilates', 'fitnes']
        }
      ]
      allow(transformer).to receive(:transform).and_return data
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.categories ).to match ['fitnes']
      subject.run
      expect( Klub.unscoped.where(name: 'Fitnes 1').first.categories ).to match ['fitnes', 'pilates']
    end
  end
end


# TODO if same club, differ category, add the category

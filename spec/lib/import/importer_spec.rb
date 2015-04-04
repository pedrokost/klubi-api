require 'rails_helper'
require 'import/importer'
require 'import/datasource'
require 'import/transformer'

require 'stringio'
require 'highline'
require 'pry'

RSpec.describe Import::Importer do

  let(:datasource) { instance_double(Import::Datasource) }
  let(:transformer) { instance_double(Import::Transformer) }
  let(:highline) { instance_double(HighLine) }
  let(:merge_resolution) { Import::Resolution.new(:merge) }
  let(:create_new_resolution) { Import::Resolution.new(:create_new) }

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

    allow(HighLine).to receive(:new).and_return highline
    allow(highline).to receive(:choose)
  end

  # Pubic methods
  it { is_expected.to respond_to :run }

  # Private methods
  it { is_expected.not_to respond_to :commit }
  it { is_expected.not_to respond_to :commit_one }

  it "should be able to commit an array of klubs data" do
    expect{subject.run}.to change{Klub.unscoped.count}.by 2
  end

  describe "it should not create duplicate klubs" do
    before do
      subject.run
      expect(Klub.unscoped.count).to eq 2
    end

    it "if same name" do
      expect { subject.run }.not_to change{Klub.unscoped.count}
    end

    it "should prompt for resolution if same name" do
      data = [
            {
              name: 'Fitnes 1',
              address: 'Cesta 5, Maribor',
              categories: ['fitnes', 'karate']
            }
          ]
      allow(transformer).to receive(:transform).and_return data
      expect(highline).to receive(:choose)

      subject.run
    end

    it "should print the most similar duplicate klub" do
      subject.run
      expect(Klub.unscoped.count).to eq(2)

      existing_klubs = Klub.unscoped

      # Add two more very similar klub
      existing_klubs.first.name = "Fitnes X"
      existing_klubs.first.address = "Metlika"
      existing_klubs.first.save!

      existing_klubs.last.name = "Fitnes X"
      existing_klubs.last.address = "Maribor"
      existing_klubs.last.save!

      # See how the method works
      klubdata = {
        name: 'Fitnes X',
        address: 'Mariborcan',
        categories: ['fitnes']
      }

      similar = subject.send(:most_similar_klub, klubdata, existing_klubs)

      expect(similar).to eq(existing_klubs.last)
    end

    it "should merge data if resolution is 'merge'" do
      allow(Import::Resolution).to receive(:new).and_return(merge_resolution)
      data = [
            {
              name: 'Fitnes 1',
              address: 'Cesta 5, Maribor',
              categories: ['fitnes', 'karate']
            }
          ]
      allow(transformer).to receive(:transform).and_return data

      subject.run

      klub = Klub.unscoped.where(name: 'Fitnes 1').first
      expect(klub.address).to eq 'Cesta 5, Maribor'
      expect(klub.categories).to match ['fitnes', 'karate']
    end

    it "should not create new klub for resoultion 'merge'" do
      allow(Import::Resolution).to receive(:new).and_return(merge_resolution)
      data = [
            {
              name: 'Fitnes 1',
              address: 'Cesta 5, Maribor',
              categories: ['fitnes', 'karate']
            }
          ]
      allow(transformer).to receive(:transform).and_return data

      expect{subject.run}.not_to change{Klub.unscoped.count}
    end

    it "should create new klub for resolution 'create new klub'" do
      expect(Import::Resolution).to receive(:new).and_return(create_new_resolution)
      data = [
            {
              name: 'Fitnes 1',
              address: 'Cesta 5, Maribor',
              categories: ['fitnes', 'karate']
            }
          ]
      allow(transformer).to receive(:transform).and_return data

      expect {subject.run}.to change{Klub.unscoped.count}.by 1
    end

    it "if same name - case sensitive" do
      allow(Import::Resolution).to receive(:new).and_return(merge_resolution)
      # FIXME: and user says merge
      data = [
        {
          name: 'FitNes 1'
        }
      ]
      allow(transformer).to receive(:transform).and_return data

      expect { subject.run }.not_to change{Klub.unscoped.count}
    end
  end

  describe "it should merge new data" do
    before do
      allow(Import::Resolution).to receive(:new).and_return(merge_resolution)
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

    it "should amend the address if missing" do
      klub = Klub.unscoped.where(name: 'Fitnes 1').first
      klub.address = nil
      klub.save!

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

    it "should amend the facebook_url if missing" do
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

    it "should amend the website if missing" do
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

    it "should amend the town if missing" do
      klub = Klub.unscoped.where(name: 'Fitnes 1').first
      klub.town = nil
      klub.save!

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

    it "should amend the phone if missing" do
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

    it "should amend the email if missing" do
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

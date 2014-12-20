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

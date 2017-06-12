require 'rails_helper'

RSpec.describe Obcina, type: :model do

  describe "category_klubs" do

    # Right half of Slovenia
    # http://dev.openlayers.org/examples/vector-formats.html
    let!(:obcina) { create(:obcina, {
        name: 'Obcina Right Slovenia',
        geom: 'MULTIPOLYGON(((14.842529296875 46.900634765625, 14.7216796875 45.274658203125, 16.666259765625 45.274658203125, 16.820068359375 46.91162109375, 14.842529296875 46.900634765625)))'
      })
    }

    it "should include klubs in the obcina" do
      klub = create(:complete_klub, name: 'Trbovlje klub', latitude: 46.117260, longitude: 15.059348, categories: ['fitnes'])

      expect( obcina.category_klubs('fitnes') ).to include klub
    end

    it "should not include klubs outside obcina" do
      klub = create(:complete_klub, name: 'Ajdovscina klub', latitude: 45.892941, longitude: 13.905172, categories: ['fitnes'])

      expect( obcina.category_klubs('fitnes') ).not_to include klub
    end

    it "should not return closed klubs" do
      klub = create(:complete_klub, name: 'Trbovlje klub', latitude: 46.117260, longitude: 15.059348, categories: ['fitnes'], closed_at: Date.today)

      expect( obcina.category_klubs('fitnes') ).not_to include klub
    end

    it "should not return unverified klubs" do
      klub = create(:complete_klub, name: 'Trbovlje klub', latitude: 46.117260, longitude: 15.059348, categories: ['fitnes'], verified: false)

      expect( obcina.category_klubs('fitnes') ).not_to include klub
    end

    it "should include only klubs of the given category" do
      klub = create(:complete_klub, name: 'Trbovlje klub', latitude: 46.117260, longitude: 15.059348, categories: ['karate'])

      expect( obcina.category_klubs('karate') ).to include klub
    end

    it "should not include klubs of another category" do
      klub = create(:complete_klub, name: 'Trbovlje klub', latitude: 46.117260, longitude: 15.059348, categories: ['karate'])

      expect( obcina.category_klubs('fitnes') ).not_to include klub
    end

    it "should only return parent if child has no category" do
      klub = create(:complete_klub, name: 'Trbovlje klub', latitude: 46.117260, longitude: 15.059348, categories: ['joga'])
      branch = create(:complete_klub_branch, latitude: 46.117260, longitude: 15.059348, parent: klub, categories: ['fitnes'])

      expect( obcina.category_klubs('joga') ).not_to include branch # goal
      expect( obcina.category_klubs('joga') ).to include klub # not goal of this test
    end

    it "should return only branch if parent has no category" do
      klub = create(:complete_klub, name: 'Trbovlje klub', latitude: 46.117260, longitude: 15.059348, categories: ['joga'])
      branch = create(:complete_klub_branch, latitude: 46.117260, longitude: 15.059348, parent: klub, categories: ['fitnes'])

      expect( obcina.category_klubs('fitnes') ).to include branch
      # I have not yet decided if parent should or should not be included here
      expect( obcina.category_klubs('fitnes') ).not_to include klub
    end
  end
end

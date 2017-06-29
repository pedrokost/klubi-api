require 'rails_helper'

RSpec.describe Obcina, type: :model do

  describe "neighbouring_obcinas" do
    let!(:obcina) { create(:obcina, {
        name: 'Obcina Right Slovenia',
        geom: 'MULTIPOLYGON(((14.842529296875 46.900634765625, 14.7216796875 45.274658203125, 16.666259765625 45.274658203125, 16.820068359375 46.91162109375, 14.842529296875 46.900634765625)))'
      })
    }

    let!(:nearby_obcina1) { create(:obcina, {
        name: 'Nearby Obcina 1',
        population_size: 100,
        geom: 'MULTIPOLYGON(((14.553623199463 46.634902954102, 14.894199371338 46.634902954102, 14.861240386963 46.327285766602, 14.487705230713 46.173477172852, 14.553623199463 46.634902954102)))'
      })
    }

    let!(:nearby_obcina2) { create(:obcina, {
        name: 'Nearby Obcinas 2',
        population_size: 1000,
        geom: 'MULTIPOLYGON(((14.454746246338 46.283340454102, 14.861240386963 46.239395141602, 14.575595855713 45.997695922852, 14.454746246338 46.283340454102)))'
      })
    }

    let!(:nearby_obcina3) { create(:obcina, {
        name: 'Nearby Obcinas 3',
        population_size: 500,
        geom: 'MULTIPOLYGON(((14.553623199463 45.854873657227, 14.839267730713 45.920791625977, 14.795322418213 45.657119750977, 14.553623199463 45.558242797852, 14.388828277588 45.558242797852, 14.553623199463 45.854873657227)))'
      })
    }


    let!(:disjoin_obcina) { create(:obcina, {
        name: 'Disjoint obcina',
        geom: 'MULTIPOLYGON(((13.707675933838 46.283340454102, 13.707675933838 45.668106079102, 14.070224761963 45.679092407227, 14.103183746338 46.228408813477, 13.707675933838 46.283340454102)))'
      })
    }

    it "does not include itself" do
      expect(obcina.neighbouring_obcinas).not_to include obcina
    end

    it "does not include disjoint obcinas" do
      expect(obcina.neighbouring_obcinas).not_to include disjoin_obcina
    end

    it "includes obcinas touching it" do
      expect(obcina.neighbouring_obcinas).to include nearby_obcina1
      expect(obcina.neighbouring_obcinas).to include nearby_obcina2
      expect(obcina.neighbouring_obcinas).to include nearby_obcina3
    end

    it "should sort the obcinas by population size" do
      expect(obcina.neighbouring_obcinas[0]).to eq nearby_obcina2
      expect(obcina.neighbouring_obcinas[1]).to eq nearby_obcina3
      expect(obcina.neighbouring_obcinas[2]).to eq nearby_obcina1
    end
  end

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

require 'import/datasource'

module Import
  class GimnasticnaZvezaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/gimnasticna_zveza.json"
      )
    end
  end
end 
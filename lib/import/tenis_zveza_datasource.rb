require 'import/datasource'

module Import
  class TenisZvezaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/tenis_zveza.csv"
      )
    end
  end
end 
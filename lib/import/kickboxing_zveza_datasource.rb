require 'import/datasource'

module Import
  class KickboxingZvezaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/kickboxing_klubi.csv"
      )
    end
  end
end 
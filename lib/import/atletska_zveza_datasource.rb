require 'import/datasource'

module Import
  class AtletskaZvezaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/atletska_zveza.json"
      )
    end
  end
end 
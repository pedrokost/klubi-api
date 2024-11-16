require 'import/datasource'

module Import
  class KzsDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/kzs_complete_zveza.json"
      )
    end
  end
end 
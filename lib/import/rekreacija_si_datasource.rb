require 'import/datasource'

module Import
  class RekreacijaSiDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/rekreacija_si.json"
      )
    end
  end
end 
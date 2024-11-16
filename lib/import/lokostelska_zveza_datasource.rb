require 'import/datasource'

module Import
  class LokostelskaZvezaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/lokostelski_klubi.csv"
      )
    end
  end
end 
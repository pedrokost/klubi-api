require 'import/datasource'

module Import
  class SloveniaWellnessDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/slovenia_wellness.json"
      )
    end
  end
end 
require 'import/datasource'

module Import
  class FitnessInfoWellnessDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/fitness_info_wellness.json"
      )
    end
  end
end 
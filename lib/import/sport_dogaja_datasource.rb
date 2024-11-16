require 'import/datasource'

module Import
  class SportDogajaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/all_sport_dogaja.json"
      )
    end
  end
end 
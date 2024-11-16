require 'import/datasource'

module Import
  class KarateKlubiDatasource < Datasource
    def initialize
      super(
        :file,
        'lib/tasks/data/karate_klubi.csv'
      )
    end
  end
end 
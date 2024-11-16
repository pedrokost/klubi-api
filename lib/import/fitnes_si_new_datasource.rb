require 'import/datasource'

module Import
  class FitnesSiNewDatasource < Datasource
    def initialize
      super(
        :file,
        'lib/tasks/data/fitnes_si_new.json'
      )
    end
  end
end 
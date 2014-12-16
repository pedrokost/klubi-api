require 'import/datasource'

module Import
  class FitnesSiDatasource < Datasource
    def initialize
      # super(
      #   :http,
      #   "http://www.fitnes.si/php/return-fitness-list.php?lat=46.0569465&lng=14.505751499999974&tags="
      # )
      super(
        :file,
        'lib/tasks/fitnes_si.xml'
      )
    end
  end
end

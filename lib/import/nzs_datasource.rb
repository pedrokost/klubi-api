require 'import/datasource'

module Import
  class NzsDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/nzs-si.json"
      )
    end
  end
end 
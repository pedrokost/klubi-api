require 'import/datasource'

module Import
  class NamiznoteniskaZvezaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/namiznoteniska_zveza.json"
      )
    end
  end
end 
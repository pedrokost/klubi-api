require 'import/datasource'

module Import
  class JudoZvezaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/judo_zveza.json"
      )
    end
  end
end 
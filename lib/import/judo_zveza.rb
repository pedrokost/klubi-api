require 'import/transformer'
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

  class JudoZvezaTransformer < Transformer
    def description
      "Import judo data from Judo Zveza Slovenije".freeze
    end

    def transform(data)
      json = JSON.parse(data)

      clean_data = []
      json['results']['collection1'].each do |klubdata|
        clean_data << klubdata.symbolize_keys
      end

      clean_data
    end
  end
end

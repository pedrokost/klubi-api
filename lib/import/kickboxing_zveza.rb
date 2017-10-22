require 'import/transformer'
require 'import/datasource'

module Import
  class KickboxingZvezaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/kickboxing_klubi.csv"
      )
    end
  end

  class KickboxingZvezaTransformer < Transformer
    def description
      "Import kickboxing data from Kickboxing Zveza Slovenije".freeze
    end

    def transform(data)
      clean_data = []

      CSV.parse(data, headers: :first_row) do |row|
        data_hash = row.to_h.symbolize_keys
        data_hash[:verified] = true
        data_hash[:categories] = ['kickbox']

        clean_data << data_hash
      end

      clean_data
    end
  end
end

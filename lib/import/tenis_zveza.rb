require 'import/transformer'
require 'import/datasource'

module Import
  class TenisZvezaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/tenis_zveza.csv"
      )
    end
  end

  class TenisZvezaTransformer < Transformer
    def description
      "Import tenis data from Tenis Zveza Slovenije".freeze
    end

    def transform(data)
      clean_data = []

      CSV.parse(data, headers: :first_row) do |row|
        data_hash = row.to_h.symbolize_keys
        data_hash.delete(:ignore)
        data_hash[:verified] = true
        data_hash[:notes] = "Oznaka #{data_hash[:notes]}"
        data_hash[:categories] = ['tenis']
        data_hash[:name] = data_hash[:name].titleize
        clean_data << data_hash
      end

      clean_data
    end
  end
end

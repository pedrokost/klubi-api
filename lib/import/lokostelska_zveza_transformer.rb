require 'import/transformer'
require 'csv'

module Import
  class LokostelskaZvezaTransformer < Transformer
    def description
      "Import lokostelska data from Lokostelska Zveza Slovenije".freeze
    end

    def transform(data)
      clean_data = []

      CSV.parse(data, headers: :first_row) do |row|
        data_hash = row.to_h.symbolize_keys
        data_hash[:verified] = true
        data_hash[:categories] = ['lokostrelstvo']

        clean_data << data_hash
      end

      clean_data
    end
  end
end 
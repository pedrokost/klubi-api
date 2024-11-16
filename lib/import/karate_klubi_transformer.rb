require 'import/transformer'
require 'csv'

module Import
  class KarateKlubiTransformer < Transformer
    def description
      "Import manually collected Karate clubs".freeze
    end

    def transform(data)
      clean_data = []

      CSV.parse(data, headers: :first_row) do |row|
        data_hash = row.to_h.symbolize_keys
        data_hash[:categories] = data_hash[:categories].split(',').map(&:strip)
        data_hash[:facebook_url] = data_hash.delete(:facebook)

        clean_data << data_hash
      end

      clean_data
    end
  end
end 
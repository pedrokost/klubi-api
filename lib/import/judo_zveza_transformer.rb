require 'import/transformer'
require 'json'

module Import
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
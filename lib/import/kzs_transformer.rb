require 'import/transformer'
require 'json'

module Import
  class KzsTransformer < Transformer
    def description
      "Import misc data from KZS".freeze
    end

    def transform(data)
      json = JSON.parse(data)
      clean_data = []

      json.each do |klubdata|
        if klubdata['address']
          klubdata['address'] = klubdata['address'].gsub("\t", '').gsub("\n", ',')
        end
        klubdata['categories'] = ['kosarka']
        klubdata['verified'] = true
        clean_data << klubdata.symbolize_keys
      end

      clean_data
    end
  end
end 
require 'import/transformer'
require 'json'

module Import
  class NamiznoteniskaZvezaTransformer < Transformer
    def description
      "Import misc data from NamiznoteniskaZveza".freeze
    end

    def transform(data)
      json = JSON.parse(data)
      clean_data = []

      json.each do |klubdata|
        klubdata['categories'] = ['namizni-tenis']
        klubdata['verified'] = true
        clean_data << klubdata.symbolize_keys
      end

      clean_data
    end
  end
end 
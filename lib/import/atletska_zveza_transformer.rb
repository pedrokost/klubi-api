require 'import/transformer'

module Import
  class AtletskaZvezaTransformer < Transformer
    def description
      "Import misc data from AtletskaZveza".freeze
    end

    def transform(data)
      json = JSON.parse(data)
      clean_data = []

      json.each do |klubdata|
        klubdata['facebook_url'] = klubdata['facebook']
        klubdata.delete('facebook')
        klubdata['categories'] = ['atletika']
        klubdata['verified'] = true
        clean_data << klubdata.symbolize_keys
      end

      clean_data
    end
  end
end 
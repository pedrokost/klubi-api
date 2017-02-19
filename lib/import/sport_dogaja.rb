require 'import/transformer'
require 'import/datasource'

module Import
  class SportDogajaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/all_sport_dogaja.json"
      )
    end
  end

  class SportDogajaTransformer < Transformer
    def description
      "Import misc data from Sport Dogaja".freeze
    end

    def transform(data)
      json = JSON.parse(data)

      clean_data = []
      json.each do |klubdata|

        klubdata['address'] = klubdata['address'].gsub("\t", '').gsub("\n", ',')
        klubdata['categories'] = [klubdata['category'].parameterize]
        klubdata.delete('category')
        clean_data << klubdata.symbolize_keys
      end

      clean_data = clean_data.uniq
    end
  end
end

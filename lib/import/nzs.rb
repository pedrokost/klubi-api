require 'import/transformer'
require 'import/datasource'

module Import
  class NZSDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/nzs-si.json"
      )
    end
  end

  class NZSTransformer < Transformer
    def description
      "Import misc data from Sport Dogaja".freeze
    end

    def transform(data)
      json = JSON.parse(data)

      clean_data = []
      json.each do |klubdata|


        klub = {
          'name': klubdata[1],
          'address': "#{klubdata[2]}, #{klubdata[3]} #{klubdata[4]}",
          'email': klubdata[5],
          'website': klubdata[6],
          'notes': "Ustanovljen leta #{klubdata[7]}",
          'categories': ['nogomet']
        }

        clean_data << klub.symbolize_keys
      end

      clean_data = clean_data.uniq
    end
  end
end

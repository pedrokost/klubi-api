require 'import/transformer'
require 'import/datasource'

module Import
  class GimnasticnaZvezaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/gimnasticna_zveza.json"
      )
    end
  end

  class GimnasticnaZvezaTransformer < Transformer
    def description
      "Import gimnastics data from gimnasticna zveza Slovenije".freeze
    end

    def transform(data)
      json = JSON.parse(data)

      clean_data = []
      json['results']['collection1'].each do |klubdata|
        name = klubdata['name']
        website = klubdata['website']
        address = klubdata['address']
        phone = klubdata['phone']
        email = klubdata['email']

        klub = {
          name: name,
          address: address,
          website: website,
          email: email,
          phone: phone,
          categories: ['gimnastika']
        }

        p klub

        clean_data << klub
      end

      clean_data
    end
  end
end

require 'import/transformer'
require 'import/datasource'

module Import
  class JudoZvezaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/judo_zveza.json"
      )
    end
  end

  class JudoZvezaTransformer < Transformer
    def description
      "Import judo data from Judo Zveza Slovenije".freeze
    end

    def transform(data)
      json = JSON.parse(data)
      # TODO

      # clean_data = []
      # json['results']['collection1'].each do |klubdata|
      #   name = klubdata['name']
      #   website = klubdata['url']
      #   address = klubdata['address']
      #   phone = klubdata['phone']
      #   email = klubdata['email']
      # #   address = address.sub('Naslov podjetja: ', '').sub('Povezava na stran podjetja', '').gsub("\n", ' ').strip

      #   klub = {
      #     name: name,
      #     address: address,
      #     website: website,
      #     email: email,
      #     phone: phone,
      #     categories: ['gimnastika']
      #   }

      #   clean_data << klub
      # end

      # clean_data
    end
  end
end

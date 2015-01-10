require 'import/transformer'

module Import
  class FitnesSiNewDatasource < Datasource
    def initialize
      super(
        :file,
        'lib/tasks/data/fitnes_si_new.json'
      )
    end
  end
  class FitnesSiNewTransformer < Transformer
    def description
      "Import results from FitneSiNew".freeze
    end

    def transform(data)
      json = JSON.parse(data)

      clean_data = []
      json['results']['collection1'].each do |klubdata|
        name = klubdata['name']
        categories = klubdata['tags'].downcase.split("\n")
        other = Hash[klubdata['address'].split("\n").in_groups_of(2)]
        address = other["Naslov:"]
        phone = other['Telefon:']
        email = other['Email:']

        k = {
          name: name,
          categories: categories,
          address: address,
          phone: phone,
          email: email
        }

        clean_data << k
      end

      clean_data
    end
  end
end

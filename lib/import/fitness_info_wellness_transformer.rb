require 'import/transformer'
require 'json'

module Import
  class FitnessInfoWellnessTransformer < Transformer
    def description
      "Import results from FitnessInfo".freeze
    end

    def transform(data)
      json = JSON.parse(data)

      clean_data = []
      json['results']['collection1'].each do |klubdata|
        name = klubdata['name']
        address = klubdata.slice('address1', 'address2', 'address3', 'address4').values
        address = Hash[ address.map{ |i| i.split(':') } ]
        town = address['Mesto'].strip
        address = address.slice('Naslov', 'Poštna številka', 'Mesto', 'Država').values.map(&:strip).join(', ')

        hashy, nohashy = klubdata.slice('contact1', 'contact2', 'contact3', 'contact4').values.partition { |i| i.is_a? Hash }
        phone = nohashy[0]
        phone = phone.split(':')[1].strip if phone

        contacts = hashy.map{ |i| i['text'] }

        facebook_url_index = contacts.find_index{ |i|  i.match /facebook/ }
        facebook_url = contacts.delete_at(facebook_url_index) if facebook_url_index
        email_index = contacts.find_index{|i| i =~ /@/}
        email = contacts.delete_at(email_index) if email_index
        website = contacts[0] unless ( contacts[0].nil? || contacts[0].match(/facebook/) )

        klub = {
          name: name,
          town: town,
          address: address,
          phone: phone,
          website: website,
          email: email,
          facebook_url: facebook_url,
          categories: ['wellness']
        }

        clean_data << klub
      end
      clean_data
    end
  end
end 
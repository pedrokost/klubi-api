require 'import/transformer'
require 'json'

module Import
  class RekreacijaSiTransformer < Transformer
    def description
      "Import misc data from RekreacijaSi".freeze
    end

    def transform(data)
      json = JSON.parse(data)

      keymapping = {
        n: :name,
        t: :town,
        c: :categories,
        a: :address,
        w: :website,
        d: :description,
        e: :email,
        p: :phone,
        la: :latitude,
        lo: :longitude,
        f: :facebook_url
      }

      clean_data = []
      json.each_with_index do |klubdata, index|
        newklubdata = {}
        klubdata.each do |k, v|
          unless keymapping.key? k.to_sym
            p "Warning, missing key: #{k}: #{v}"
          end
          newklubdata[keymapping[k.to_sym]] = v
        end
        newklubdata[:categories] = [newklubdata[:categories]]
        newklubdata[:latitude] = newklubdata[:latitude].to_d
        newklubdata[:longitude] = newklubdata[:longitude].to_d
        newklubdata[:verified] = true

        clean_data << newklubdata
      end

      clean_data
    end
  end
end 
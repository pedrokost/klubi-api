#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-10-21 11:04:39
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-10-21 11:08:57

require 'import/transformer'
require 'import/datasource'
require 'pry'

module Import
  class AtletskaZvezaDatasource < Datasource
    def initialize
      super(
        :file,
        "lib/tasks/data/atletska_zveza.json"
      )
    end
  end

  class AtletskaZvezaTransformer < Transformer
    def description
      "Import misc data from AtletskaZveza".freeze
    end

    def transform(data)
      json = JSON.parse(data)
      clean_data = []

      json.each do |klubdata|
        # if klubdata['address']
        #   klubdata['address'] = klubdata['address'].gsub("\t", '').gsub("\n", ',')
        # end
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

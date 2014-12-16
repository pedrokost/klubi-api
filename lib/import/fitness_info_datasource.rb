require 'import/datasource'

module Import
  class FitnessInfoDatasource < Datasource
    def initialize
      super(
        :http,
        "https://www.kimonolabs.com/api/atqwtfs6?apikey=#{ENV['KIMONO_LABS_API_KEY']}"
      )
    end
  end
end

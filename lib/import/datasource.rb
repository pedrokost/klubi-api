require 'rest_client'

module Import
  class Datasource
    def initialize(type, path)
      @type = type
      @path = path
    end

    def fetch
      case @type
      when :file
        File.read @path
      when :http
        RestClient.get @path
      else
        p "Not yet implemented"
      end
    end
  end
end

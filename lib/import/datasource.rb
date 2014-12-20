require 'rest_client'

module Import
  class Datasource
    def initialize(type, path, verbose=false)
      @type = type
      @path = path
      @verbose = verbose
    end

    def fetch
      case @type
      when :file
        File.read @path
      when :http
        RestClient.get @path
      else
        p "Not yet implemented" if @verbose
      end
    end
  end
end

module Import
  class Importer
    def initialize(datasource, transformer)
      @transformer = transformer
      @datasource = datasource
    end

    def run
      p @transformer.description
      raw_data = @datasource.fetch
      clean_data = @transformer.transform raw_data
      commit(clean_data)
    end

  private

    def commit(klubsdata)
      klubsdata.each do |klubdata|
        commit_one(klubdata)
        sleep 0.2  # Make sure you don't make more than 5 reqs per second
      end
    end

    def commit_one(klubdata)
      if Klub.unscoped.where(name: klubdata[:name]).empty?
        klub = Klub.new(klubdata)
        print klub.name

        if klub.valid?
          print " OK\n"
          # TODO: recompute lat/long if
          klub.save!
          return klub
        else
          print " INVALID\n"
          # TODO: Send me an email with the klub data
          # Or at least log it so I can find it later
        end
      else
        p "Duplicate klub", klubdata
      end

    end
  end
end

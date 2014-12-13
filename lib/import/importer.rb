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
      end
    end

    def commit_one(klubdata)
      if Klub.unscoped.where(name: klubdata['name'], town: klubdata['town']).empty?
        klub = Klub.new(klubdata)
        if klub.valid?
          # TODO: recompute lat/long if
          klub.save!
          return klub
        else
          # TODO: Send me an email with the klub data
          # Or at least log it so I can find it later
          render nil
        end
      else
        p "Duplicate klub", klub
      end
    end
  end
end

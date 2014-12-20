module Import
  class Importer
    def initialize(datasource, transformer, verbose=true)
      @transformer = transformer
      @datasource = datasource
      @verbose = verbose
    end

    def run
      p @transformer.description if @verbose
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
      # TODO: test no duplicates
      tbl = Klub.arel_table
      existing_klub = Klub.unscoped.where(tbl[:name].matches(klubdata[:name]))

      if existing_klub.empty?
        klub = Klub.new(klubdata)
        print klub.name if @verbose

        if klub.valid?
          print " OK\n" if @verbose
          # TODO: recompute lat/long if
          klub.save!
          return klub
        else
          print " INVALID\n" if @verbose
          # TODO: Send me an email with the klub data
          # Or at least log it so I can find it later
        end
      else
        p "Duplicate klub. Possibly merge categories", klubdata if @verbose

        return unless klubdata[:categories]

        existing_klub = existing_klub.first
        existing_klub.categories = (existing_klub.categories + klubdata[:categories]).uniq
        existing_klub.save!

      end

    end
  end
end

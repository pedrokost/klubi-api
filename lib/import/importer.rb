require 'pry' if Rails.env.test?

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
        sleep 0.2 unless Rails.env.test? # Make sure you don't make more than 5 reqs per second
      end
    end

    def commit_one(klubdata)
      tbl = Klub.arel_table
      existing_klub = Klub.unscoped.where(tbl[:name].matches(klubdata[:name]))

      existing_klub = [Klub.new] if existing_klub.empty?
      existing_klub.each do |klub|
        klub.merge_with(klubdata)
        klub.save!
      end
    end
  end
end

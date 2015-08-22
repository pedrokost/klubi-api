require 'highline'
require 'pry' if Rails.env.test?
require 'pp'

module Import
  class Resolution
    attr_accessor :resolution
    def initialize(merge_or_create_new = nil)
      @resolution = merge_or_create_new
    end
  end

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
      p "Creating club #{klubdata[:name]}" if @verbose

      tbl = Klub.arel_table
      existing_klubs = Klub.unscoped.where(tbl[:name].matches(klubdata[:name]))

      if existing_klubs.empty?
        Klub.new(klubdata).save!
        return
      end

      klub = most_similar_klub(klubdata, existing_klubs)
      pp '=' * 60 if @verbose
      p 'Existing klub:' if @verbose
      pp klub.as_json.symbolize_keys if @verbose
      p 'New data:' if @verbose
      pp klubdata.as_json.symbolize_keys if @verbose

      h = HighLine.new
      selection = Resolution.new
      h.choose do |menu|
        menu.prompt = "Merge data into existing klub or Create new klub?" if @verbose
        menu.choice(:merge) { selection = Resolution.new(:merge) }
        menu.choices(:create_new) { selection = Resolution.new(:create_new) }
      end
      case selection.resolution
      when :merge
          klub.merge_with(klubdata)
          h.say("DONE merging klubs' data") if @verbose
      when :create_new
          klub = Klub.new(klubdata)
          h.say("DONE creating new klub") if @verbose
      end

      klub.save!
    end

    def most_similar_klub(klubdata, existing_klubs)
      # Returns the klub from existing_klubs that is most similar to the
      # klubdata hash in terms of sum of Levenshtein distance between selected
      # attributes

      attrs = [:name, :address]
      # Reject any attributes which are not set in all objects
      attrs.delete_if do |attr|
        klubdata[attr] == nil || existing_klubs.any?{ |k| k.send(attr) == nil }
      end

      existing_klubs.min_by do |klub|
        sum = 0
        attrs.each do |attr|
          sum = sum + Levenshtein.distance(klubdata[attr], klub.send(attr))
        end
        sum
      end
    end
  end
end

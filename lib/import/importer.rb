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

    def run(do_not_merge: [])
      @do_not_merge = do_not_merge
      p @transformer.description if @verbose
      raw_data = @datasource.fetch
      clean_data = @transformer.transform raw_data

      commit(clean_data)
    end

  private

    def commit(klubsdata)
      klubsdata.each_with_index do |klubdata, index|
        commit_one(klubdata)
        sleep 0.2 unless Rails.env.test? # Make sure you don't make more than 5 reqs per second
        break if index > 10
      end
    end

    def commit_one(klubdata)
      p "Creating klub #{klubdata[:name]}" if @verbose

      tbl = Klub.arel_table
      existing_klubs = Klub.unscoped.where(tbl[:name].matches(klubdata[:name]))

      klub = most_similar_klub(klubdata, existing_klubs)

      if not klub
        klub = Klub.new(klubdata)
        p 'New klub:' if @verbose
        pp klub.as_json.symbolize_keys if @verbose
        klub.save!
      else
        pp '=' * 60 if @verbose

        if @verbose
          pp klubdata

          print_keys = %w(name address town latitude longitude email phone website facebook_url categories description verified)
          command = "diff  <(echo '#{klub.slice(print_keys).to_json}' | jq --sort-keys --color-output .) <(echo '#{klubdata.to_json}' | jq -SC .)"
          system("bash", "-c", command)
        end

        cli = TTY::Prompt.new
        selection = Resolution.new
        user_selection = cli.enum_select("Merge data into existing klub or Create new klub?") do |menu|
          menu.default 2 # safer choice

          menu.choice "Selective override", Resolution.new(:override)
          menu.choice "Merge, prefer old",  Resolution.new(:merge_left)
          menu.choice "Merge, prefer new", Resolution.new(:merge_right)
          menu.choice "Create new",  Resolution.new(:create_new)
          menu.choice "Create branch", Resolution.new(:create_branch)
          menu.choice "Skip",        Resolution.new(:skip)
        end

        handle_merge_choice(cli, user_selection.resolution, klub, klubdata)
      end
    end

    def most_similar_klub(klubdata, existing_klubs)
      # Returns the klub from existing_klubs that is most similar to the
      # klubdata hash in terms of sum of Levenshtein distance between selected
      # attributes

      attrs = [:name, :address, :email]
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

    def select_klubdata_to_keep(cli, klubdata)
      keep = cli.multi_select("Which to override?", echo: false, per_page: 20) do |menu|
        menu.default *(1..klubdata.size).to_a

        klubdata.each do |k, v|
          menu.choice "#{k} - #{v}", k
        end
      end

      klubdata.slice(*keep)
    end

    def handle_merge_choice(cli, user_selection, klub, klubdata)
      case user_selection
      when :merge_left
        kd = select_klubdata_to_keep(cli, klubdata)
        klub.merge_left_with(kd, skip: @do_not_merge)
        cli.ok("DONE left merging klubs' data") if @verbose
        klub.save!
      when :merge_right
        require 'pry'; binding.pry unless Rails.env.test? # let me adjust stuff before merging
        klub.merge_right_with(klubdata, skip: @do_not_merge)
        cli.ok("DONE right merging klubs' data") if @verbose
        klub.save!
      when :create_new
        klub = Klub.new(klubdata)
        cli.ok("DONE creating new klub") if @verbose
        klub.save!
      when :skip
        cli.ok('SKIPPING klub') if @verbose
      else
        cli.error('Invalid options selected', user_selection)
      end
    end
  end
end

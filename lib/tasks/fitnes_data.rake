require 'rest_client'
require 'import/importer'
require 'import/fitness_info_transformer'
require 'import/fitness_info_datasource'

namespace :import do

  # TODO: metaprogram this thing

  desc "Import fitness data from fitness-info.si"
  task :fitness_info => :environment do
    transformer = Import::FitnessInfoTransformer.new
    data_source = Import::FitnessInfoDatasource.new
    Import::Importer.new(data_source, transformer).run
  end
end


require 'rest_client'
require 'import/importer'
require 'import/fitness_info_transformer'
require 'import/fitness_info_datasource'
require 'import/fitnes_si_transformer'
require 'import/fitnes_si_datasource'

namespace :import do

  # TODO: metaprogram this thing

  desc "Import fitness data from fitness-info.si"
  task :fitness_info => :environment do
    transformer = Import::FitnessInfoTransformer.new
    data_source = Import::FitnessInfoDatasource.new
    Import::Importer.new(data_source, transformer).run
  end

  task :fitnes_si => :environment do
    transformer = Import::FitnesSiTransformer.new
    data_source = Import::FitnesSiDatasource.new
    Import::Importer.new(data_source, transformer).run
  end
end


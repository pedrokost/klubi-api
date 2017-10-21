require 'rest_client'
require 'import/importer'
require 'import/fitness_info_transformer'
require 'import/fitness_info_datasource'
require 'import/fitnes_si_transformer'
require 'import/fitnes_si_datasource'
require 'import/slovenia_wellness'
require 'import/fitness_info_wellness'
require 'import/fitnes_si_new'
require 'import/karate_klubi'
require 'import/gimnasticna_zveza'
require 'import/judo_zveza'
require 'import/sport_dogaja'
require 'import/tenis_zveza'
require 'import/nzs'
require 'import/kzs'
require 'import/atletska_zveza'
require 'import/namiznoteniska_zveza'

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

  task :slovenia_wellness => :environment do
    transformer = Import::SloveniaWellnessTransformer.new
    data_source = Import::SloveniaWellnessDatasource.new
    Import::Importer.new(data_source, transformer).run
  end

  task :fitness_info_wellness => :environment do
    transformer = Import::FitnessInfoWellnessTransformer.new
    data_source = Import::FitnessInfoWellnessDatasource.new
    Import::Importer.new(data_source, transformer).run
  end

  task :fitnes_si_new => :environment do
    transformer = Import::FitnesSiNewTransformer.new
    data_source = Import::FitnesSiNewDatasource.new
    Import::Importer.new(data_source, transformer).run
  end

  task :karate_klubi => :environment do
    transformer = Import::KarateKlubiTransformer.new
    data_source = Import::KarateKlubiDatasource.new
    Import::Importer.new(data_source, transformer).run
  end

  task :gimnasticna_zveza => :environment do
    transformer = Import::GimnasticnaZvezaTransformer.new
    data_source = Import::GimnasticnaZvezaDatasource.new
    Import::Importer.new(data_source, transformer).run
  end

  task :judo_zveza => :environment do
    transformer = Import::JudoZvezaTransformer.new
    data_source = Import::JudoZvezaDatasource.new
    Import::Importer.new(data_source, transformer).run
  end

  task :sport_dogaja => :environment do
    transformer = Import::SportDogajaTransformer.new
    data_source = Import::SportDogajaDatasource.new
    Import::Importer.new(data_source, transformer).run(do_not_merge: [:address])
  end

  task :nzs => :environment do
    transformer = Import::NZSTransformer.new
    data_source = Import::NZSDatasource.new
    Import::Importer.new(data_source, transformer).run()
  end

  task :tenis_zveza => :environment do
    transformer = Import::TenisZvezaTransformer.new
    data_source = Import::TenisZvezaDatasource.new
    Import::Importer.new(data_source, transformer).run()
  end

  task :kzs => :environment do
    transformer = Import::KZSTransformer.new
    data_source = Import::KZSDatasource.new
    Import::Importer.new(data_source, transformer).run()
  end

  task :atletska_zveza => :environment do
    transformer = Import::AtletskaZvezaTransformer.new
    data_source = Import::AtletskaZvezaDatasource.new
    Import::Importer.new(data_source, transformer).run()
  end

  task :namiznoteniska_zveza => :environment do
    transformer = Import::NamiznoteniskaZvezaTransformer.new
    data_source = Import::NamiznoteniskaZvezaDatasource.new
    Import::Importer.new(data_source, transformer).run()
  end
end


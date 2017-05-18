# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'
require 'pry'

Obcina.delete_all
StatisticnaRegija.delete_all

if StatisticnaRegija.all.count == 0
  connection = ActiveRecord::Base.connection()

  # Import country data from shpfile to countries table
  from_country_shp_sql = `shp2pgsql -c -g geom -s 3912:4326 -W UTF8 #{Rails.root.join('lib', 'assets', 'shpfiles', 'statisticne_regije', 'f1f60b8a-6513-5102-987c-4950a36c72ec.shp')} public.statisticne_regije_ref`
  connection.execute "drop table if exists public.statisticne_regije_ref"
  connection.execute from_country_shp_sql
  connection.execute <<-SQL
      insert into statisticna_regijas(name, slug, population_size, geom, created_at, updated_at)
        select sr_ime, sr_ime, tot_p::int, geom, now(), now() from public.statisticne_regije_ref
  SQL
  connection.execute "drop table public.statisticne_regije_ref"

  StatisticnaRegija.pluck(:id, :slug).each do |id, slug|
    if slug == "JUGOVZHODNA SLOVENIJA"
      slug = "JUGOVZHODNA"
    end
    StatisticnaRegija.where(id: id).update_all(
      slug: slug.parameterize,
      name: slug.downcase.gsub(/\b('?[\p{L}])/) { $1.capitalize }
    )
  end

  p "Successfully inserted #{StatisticnaRegija.all.count} Statistical Regions"
end

if Obcina.all.count == 0
  connection = ActiveRecord::Base.connection()

  # Import country data from shpfile to countries table
  from_country_shp_sql = `shp2pgsql -c -g geom -s 3912:4326 -W UTF8 #{Rails.root.join('lib', 'assets', 'shpfiles', 'obcine', '39a05f4e-8505-502f-bce2-4eee8a54740a.shp')} public.obcine_ref`
  connection.execute "drop table if exists public.obcine_ref"
  connection.execute from_country_shp_sql
  connection.execute <<-SQL
      insert into obcinas(name, slug, population_size, geom, created_at, updated_at)
        select ob_ime, ob_ime, tot_p::int, geom, now(), now() from public.obcine_ref
  SQL
  connection.execute "drop table public.obcine_ref"

  # Update slugs
  Obcina.pluck(:id, :slug).each do |id, slug|

    slug = "Sveta Trojica v Slovenskih goricah" if slug == "SV. TROJICA V SLOV. GORICAH"
    slug = "Sveti Jurij v Slovenskih goricah" if slug == "SVETI JURIJ V SLOV. GORICAH"
    slug = "Sveti Andraž v Slovenskih goricah" if slug == "SVETI ANDRAŽ V SLOV. GORICAH"

    Obcina.where(id: id).update_all(
      slug: slug.parameterize,
      name: slug.downcase.gsub(/\b('?[\p{L}])/) { $1.capitalize }
    )
  end

  # Add pointer to statistical region
  csv_text = File.read(Rails.root.join('lib', 'assets', 'shpfiles','obcine_z_regijami.csv'))
  csv = CSV.parse(csv_text, :headers => true)
  csv.each do |row|
    statisticna_regija = StatisticnaRegija.where(slug: row["Statistična regija"].parameterize)
    p "WARNING: couldn't find statistical region: #{row}" unless statisticna_regija
    obcina = Obcina.where(slug: row["Ime občine"].parameterize)
    p "WARNING: couldn't find obcina: #{row}" unless obcina

    obcina = obcina.first
    obcina.statisticna_regija = statisticna_regija.first
    obcina.save!
  end

  p "Successfully inserted #{Obcina.all.count} Obcinas"
end

desc "This task is called by the Heroku cron add-on"
task :wake_dyno_up => :environment do
   puts "Waking up zatresi.si"
   uri = URI.parse('http://www.zatresi.si/')
   Net::HTTP.get(uri)
   puts "zatresi.si was called."
 end

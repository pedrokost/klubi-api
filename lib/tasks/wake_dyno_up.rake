desc "This task is called by the Heroku cron add-on"
task :wake_dyno_up => :environment do
  # Wake up the app if its daytime in Slovenia
  start_time_utc = 5
  end_time_utc = 21
  if (start_time_utc..end_time_utc).cover? Time.now.getutc.hour
    puts "Waking up zatresi.si"
    uri = URI.parse('http://www.zatresi.si/')
    Net::HTTP.get(uri)
    puts "zatresi.si was called."
  else
    puts "Not waking up zatresi.si -> everybody is sleeping"
  end
 end

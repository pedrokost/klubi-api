# README

* Ruby version

* System dependencies

* Configuration

* Database creation

```
sudo su - postgres
psql template1

create user zatresi with password 'pass';
CREATE DATABASE "zatresi-api_development";
GRANT ALL PRIVILEGES ON DATABASE "zatresi-api_development" to zatresi;
CREATE DATABASE "zatresi-api_test";
GRANT ALL PRIVILEGES ON DATABASE "zatresi-api_test" to zatresi;
\q
```

* Database initialization

```
foreman run rake db:migrate RAILS_ENV=development
foreman run rake db:test:prepare
```

Import latest production backup to local db
```
heroku pg:backups:capture
heroku pg:backups:download

pg_restore --verbose --clean --no-acl --no-owner -h localhost -U zatresi -d zatresi-api_development latest.dump
rm latest.dump
```

Altnatively, run `rake db:seed` to seed default data into the database.

* How to run the test suite

```
foreman run rspec spec/
```

* Services (job queues, cache servers, search engines, etc.)

## Deployment instructions

https://github.com/cyberdelia/heroku-geo-buildpack/
```
heroku buildpacks:set https://github.com/cyberdelia/heroku-geo-buildpack.git
heroku buildpacks:add heroku/ruby
```

```
git push heroku master
```

Setup the cron job to execute `rake sitemap:refresh` regularly (e.g. daily)

Sitemap:
```
rake sitemap:refresh
rake sitemap:refresh:no_ping
```

## Tasks

1. Daily: Send an email for accepted klub updates
```
foreman run rake updates:send_emails
```

2. Daily: Send email to request data verification to klubs
```
foreman run rake klubs:send_emails
```

foreman run rails s puma -b 'ssl://127.0.0.1:3200?key=/home/vagrant/.ssh/server.key&cert=/home/ubuntu/.ssh/server.crt'

# Resources

- [Loading data into PostGIS from the Command Line](http://suite.opengeo.org/docs/latest/dataadmin/pgGettingStarted/shp2pgsql.html)

```
shp2pgsql -I -s 3912:4326 f1f60b8a-6513-5102-987c-4950a36c72ec.shp public.statisticne_regije_testff | psql -h localhost -U zatresi -d zatresi-api_development
```

- [PostGIS and Google Maps in Rails Part 1](http://climber2002.github.io/blog/2014/05/18/postgis-and-google-maps-in-rails-part-1/)
- [Geo-Rails Part 2: Setting Up a Geospatial Rails App](http://daniel-azuma.com/articles/georails/part-2)

# Attribution

Source of administrative regions: Statistical Office of the Republic of Slovenia.

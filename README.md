# Klubi Slovenije

[![View performance data on Skylight](https://badges.skylight.io/status/pkiwulxFzCaH.svg)](https://oss.skylight.io/app/applications/pkiwulxFzCaH)
[![View performance data on Skylight](https://badges.skylight.io/typical/pkiwulxFzCaH.svg)](https://oss.skylight.io/app/applications/pkiwulxFzCaH)

- Configuration

To configure the `WANTED_OUTGOING_EMAIL_DISTRIBTION` env variable use something like this:

```
# During rounding you loose precesion, need to make it again a distribution
d_unnormalized = ([0] * 6 + [1.0/12] * 15 + [0] * 3).map{ |e| e + 0.01 }
sum_d = d_unnormalized.sum.to_f
d_normalized = d_unnormalized.map{ |e| (e / sum_d).round(2) }
sum_d = d_normalized.sum.to_f
max_index = d_normalized.each_with_index.max[1]
d_normalized[max_index] += (1 - sum_d)
d_normalized[max_index] = d_normalized[max_index].round(2)
raise "Distribution does not sum to 1" unless d_normalized.sum.round(4) == 1.0
raise "Distribution is not of length 24" unless d_normalized.length == 24
p d_normalized.join(',')
```

This gives a tiny chance to nighly emails!

- Database creation

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

- Database initialization

```
foreman run bundle exec rake db:migrate RAILS_ENV=development
foreman run bundle exec rake db:test:prepare
```

Import latest production backup to local db

```
heroku pg:backups:capture
heroku pg:backups:download

pg_restore --verbose --clean --no-acl --no-owner -h localhost -U zatresi -d zatresi-api_development latest.dump
rm latest.dump
```

Altnatively, run `rake db:seed` to seed default data into the database.

- How to run the test suite

```
foreman run bundle exec rspec spec/
```

- Services (job queues, cache servers, search engines, etc.)

- [Creating missing certification for development](https://gist.github.com/tadast/9932075)

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

## Local running

In /etc/hosts add `127.0.0.1   api.app.local`
In /etc/hosts add `127.0.0.1   admin.app.local`

Run server, then open:

http://api.app.local:3200/klubs?category=fitnes

Or to see the Administrate dashboard, open

http://admin.app.local:3200/klubs

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

3. Manual: To import data

Create a new DataSource and a new Transformer for the data.
Register it in data_import.rake

```
foreman run rake import:your_import_script
```

# Resources

- [Loading data into PostGIS from the Command Line](http://suite.opengeo.org/docs/latest/dataadmin/pgGettingStarted/shp2pgsql.html)

```
shp2pgsql -I -s 3912:4326 f1f60b8a-6513-5102-987c-4950a36c72ec.shp public.statisticne_regije_testff | psql -h localhost -U zatresi -d zatresi-api_development
```

- [PostGIS and Google Maps in Rails Part 1](http://climber2002.github.io/blog/2014/05/18/postgis-and-google-maps-in-rails-part-1/)
- [Geo-Rails Part 2: Setting Up a Geospatial Rails App](http://daniel-azuma.com/articles/georails/part-2)
- [PostGIS and Rails: A Simple Approach](http://ngauthier.com/2013/08/postgis-and-rails-a-simple-approach.html)

# Attribution

Source of administrative regions: Statistical Office of the Republic of Slovenia.


# Troubleshooting


lavenshtein gem does not seem to be building the so file.

If you get this error:

```
./ext/levenshtein/levenshtein: cannot open shared object file: No such file or directory.
```

Follow the steps here https://github.com/dbalatero/levenshtein-ffi/issues/13 to build the gem.
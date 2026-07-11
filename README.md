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

# Development

This website is deployed on a [fly.io](https://fly.io) cluster.
It uses a Dockerfile to build the image (the same production image can also be run locally, see "Local running with Docker" below).

Ruby version: see `.ruby-version` (managed with [rv](https://github.com/spinel-coop/rv), e.g. `rv ruby install 3.3.5`).
To build gems on the host you need dev headers: `sudo apt-get install libyaml-dev libpq-dev` (psych and pg fail to compile without them).

- Database creation

The easiest way is a PostGIS container matching `config/database.yml` (dev/test expect port 5434, user `zatresi`, password `pass`):

```
docker network create klubi
docker run -d --name klubi-postgis --network klubi -p 5434:5432 \
  -e POSTGRES_USER=zatresi -e POSTGRES_PASSWORD=pass \
  -e POSTGRES_DB=zatresi-api_development \
  postgis/postgis:16-3.4
```

Alternatively, on a host-installed Postgres (needs the PostGIS extension, and adjust the port in `config/database.yml`):

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

Backups are taken automatically from the Fly Postgres app by the `klubi-db-backups` repo (GitHub Action doing `fly proxy` + `pg_dump`, plain SQL format). To restore one into the local PostGIS container:

```
docker exec -i klubi-postgis psql -U zatresi -d zatresi-api_development < ../../klubi-db-backups/backup.sql
```

(Ownership errors for roles like `klubi_si_api`/`postgres` are harmless — those roles only exist in production.)

Alternatively, run `rake db:seed` to seed default data into the database.

- How to run the test suite

```
foreman run bundle exec rspec spec/
```

- Services (job queues, cache servers, search engines, etc.)

- [Creating missing certification for development](https://gist.github.com/tadast/9932075)

## Deployment instructions

Deploy to Fly.io

```
fly deploy
```

Note: `RAILS_MASTER_KEY` is provided at runtime via `fly secrets` (set once with `fly secrets set RAILS_MASTER_KEY=$(cat config/master.key)`); the Dockerfile does not take it as a build arg.

Requirements:

- Postgres with Postgis

Postgres setup:

```
fly postgres connect -a klubi-api-db
CREATE EXTENSION postgis  # Crashes if less than 512MB ram.
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

## Local running with Docker

The production image can be run locally against the PostGIS container (see "Database creation" above) — this exercises the exact image Fly deploys:

```
docker build -t klubi-si-api .
docker run -d --name klubi-api --network klubi -p 3000:3000 \
  --env-file .env \
  -e RAILS_ENV=production -e RACK_ENV=production -e PORT=3000 \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  -e DATABASE_URL=postgis://zatresi:pass@klubi-postgis:5432/zatresi-api_development \
  klubi-si-api
```

The entrypoint runs `db:prepare` on boot. Because routes are subdomain-constrained and production forces SSL, smoke-test with explicit headers:

```
curl -H "Host: api.app.local" -H "X-Forwarded-Proto: https" "http://localhost:3000/klubs?category=fitnes"
curl -H "Host: www.app.local" -H "X-Forwarded-Proto: https" "http://localhost:3000/heartbeat"
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

3. Manual: To import data

Create a new DataSource and a new Transformer for the data.
Register it in data_import.rake

```
foreman run rake import:your_import_script
```

# Cronjob

Cronjobs are run via a separate Fly project called fly-cron-manager.
To define the cronjobs, update the schedules.json file in that project.
Note/TODO: periodically build images for the jobs. Currently relying on some random deployment image.

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

levenshtein gem does not seem to be building the so file.

If you get this error:

```
./ext/levenshtein/levenshtein: cannot open shared object file: No such file or directory.
```

Follow the steps here https://github.com/dbalatero/levenshtein-ffi/issues/13 to build the gem.

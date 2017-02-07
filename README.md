# README

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

## Deployment instructions

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

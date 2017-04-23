#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-03-26 14:03:27
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-03-26 19:28:17


workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end

# if you are not using rails, just remove this conditional
if ENV.fetch("RACK_ENV") == 'development'
  ssl_bind '0.0.0.0', ENV.fetch('SSL_PORT'), {
    key: '/home/vagrant/.ssh/server.key',
    cert: '/home/vagrant/.ssh/server.crt',
    verify_mode: 'none'
  }
end

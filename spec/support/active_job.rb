#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-10-29 14:18:59
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-10-29 14:19:07

RSpec.configure do |config|
  config.include ActiveJob::TestHelper

  config.before(:each) do
    clear_enqueued_jobs
  end
end

ActiveJob::Base.queue_adapter = :test

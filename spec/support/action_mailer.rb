#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-10-29 14:17:21
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-10-29 14:17:35

RSpec.configure do |config|
  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end
end

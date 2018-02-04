#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2018-02-03 21:21:23
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2018-02-04 19:37:08

require 'json'
require 'rails_helper'
require 'google_analytics_fetcher'
require 'ostruct'

RSpec.describe GoogleAnalyticsFetcher do

  context "total_pageviews" do
    it "should return number of pageviews" do
      expect_any_instance_of(Google::Apis::AnalyticsreportingV4::AnalyticsReportingService).to receive(:batch_get_reports).and_return JSON.parse("{\"reports\":[{\"columnHeader\":{\"metricHeader\":{\"metricHeaderEntries\":[{\"name\":\"users\",\"type\":\"INTEGER\"}]}},\"data\":{\"maximums\":[{\"values\":[\"40\"]}],\"minimums\":[{\"values\":[\"40\"]}],\"rowCount\":1,\"rows\":[{\"metrics\":[{\"values\":[\"40\"]}]}],\"totals\":[{\"values\":[\"40\"]}]}}]}", object_class: OpenStruct)

      fetcher = GoogleAnalyticsFetcher.new
      pageviews = fetcher.total_visitors(140)
      expect(pageviews).to eq 40
    end

    it "should return nil when request fails" do
      expect_any_instance_of(Google::Apis::AnalyticsreportingV4::AnalyticsReportingService).to receive(:batch_get_reports).and_raise(Faraday::ConnectionFailed)
      fetcher = GoogleAnalyticsFetcher.new
      pageviews = fetcher.total_visitors(140)
      expect(pageviews).to eq nil
    end
  end

end

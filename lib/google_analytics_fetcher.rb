#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2018-02-03 21:14:00
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2018-02-04 20:56:16

# Create credentials json file
# 1. Go to Google API Console
# 2. Create credentials (Service Account Key). Note 'Service account ID'
# 3. Download key as 'google_auth.json'
# 4. Go to Google Analytics -> Admin -> View Settings. Note 'View ID'
# 5. Go to User Management -> Add permissions for: (Service account ID) [Read & Analyze]

require 'google/apis/analyticsreporting_v4'
require 'googleauth'

class GoogleAnalyticsFetcher
  # Returns the total number of visits for given klub

  SCOPE = 'https://www.googleapis.com/auth/analytics.readonly'.freeze

  def total_visitors(klub_id)

    analytics = Google::Apis::AnalyticsreportingV4::AnalyticsReportingService.new

    creds = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: StringIO.new(ENV.fetch('GOOGLE_APIS_CREDENTIALS')),
                                                               scope: SCOPE)
    analytics.authorization = creds

    date_range = Google::Apis::AnalyticsreportingV4::DateRange.new(start_date: '2016-01-01', end_date: 'today')
    # metric_pageviews = Google::Apis::AnalyticsreportingV4::Metric.new(expression: 'ga:pageviews', alias: 'pageviews')
    metric_users = Google::Apis::AnalyticsreportingV4::Metric.new(expression: 'ga:users', alias: 'users')

    request = Google::Apis::AnalyticsreportingV4::GetReportsRequest.new(
      report_requests: [Google::Apis::AnalyticsreportingV4::ReportRequest.new(
        view_id: ENV.fetch('GOOGLE_ANALYTICS_VIEW'),
        metrics: [metric_users],
        date_ranges: [date_range],
        filters_expression: "ga:pagePath=@-#{klub_id}/"
      )]
    )

    begin
      response = analytics.batch_get_reports(request)
      return nil unless response.reports && response.reports.first.data.rows
      users = response.reports.first.data.rows.first.metrics.first.values.first.to_i
      # pageviews = response.reports.first.data.rows.first.metrics.last.values.first.to_i

      users
    rescue Exception => e
      Raygun.track_exception(e)
      nil
    end
  end
end

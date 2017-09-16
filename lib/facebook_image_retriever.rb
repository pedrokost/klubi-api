#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-09-16 21:12:23
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-09-17 19:43:02

class FacebookImageRetriever
  attr_reader :page_id

  def initialize(opts)
    @page_id = opts[:page_id]
  end

  def photos
    @oauth = Koala::Facebook::OAuth.new(ENV.fetch('FB_APP_ID'), ENV.fetch('FB_APP_SECRET'))
    @graph = Koala::Facebook::API.new(@oauth.get_app_access_token)
    profile_images = @graph.get_object("#{page_id}/photos", fields: ['images'])
    uploaded_images = @graph.get_object("#{page_id}/photos?type=uploaded", fields: ['images'])

    return [[profile_images, 'profile_photo'], [uploaded_images, 'photo']].map do |images, type|
      images.map do |image|
        large = image['images'].first
        thumbnail = image['images'].last
        Image.new(
          id: image['id'],
          type: type,
          large: {
            url: large['source'],
            width: large['width'],
            height: large['height']
          },
          thumbnail: {
            url: thumbnail['source'],
            width: thumbnail['width'],
            height: thumbnail['height']
          }
        )
      end
    end.flatten

  rescue Exception => e
    p e unless Rails.env.test?
    Rails.logger.error e
    Raygun.track_exception(e)

    return []
  end
end

#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-03-19 11:38:54
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-03-19 11:45:53

module EmailHelper
  def email_image_tag(image, **options)
    # Use asset_path to get the compiled asset path
    image_path = Rails.root.join('public', asset_path(image).sub(/\A\//, ''))
    

    attachments.inline[image] = File.read(image_path)
    image_tag attachments[image].url, **options
  end
end

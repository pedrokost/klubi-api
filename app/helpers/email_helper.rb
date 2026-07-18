#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-03-19 11:38:54
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-03-19 11:45:53

module EmailHelper
  def email_image_tag(image, **options)
    # In dev/test the live asset pipeline serves the image; in production
    # (config.assets.compile = false) read the precompiled file from public/
    attachments.inline[image] =
      if (asset = Rails.application.assets&.[](image))
        asset.to_s
      else
        File.binread(Rails.root.join('public', asset_path(image).sub(/\A\//, '')))
      end
    image_tag attachments[image].url, **options
  end
end

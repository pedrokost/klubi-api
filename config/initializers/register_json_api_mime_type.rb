#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-01-28 21:26:07
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-01-28 21:28:46

api_mime_types = %W(
  application/vnd.api+json
  text/x-json
  application/json
)

Mime::Type.unregister :json
Mime::Type.register 'application/json', :json, api_mime_types

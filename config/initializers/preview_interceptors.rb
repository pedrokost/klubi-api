#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-03-19 11:47:05
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-03-19 12:07:05

ActionMailer::Base.register_preview_interceptor(ActionMailer::InlinePreviewInterceptor)

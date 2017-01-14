#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2016-11-20 14:20:02
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-01-14 18:16:33

class SendUpdateAcceptedEmails
  # Sends emails daily for all accepted updates to the editors to notify and
  # thank them for the update

  def groups
    update_groups = Update.should_notify.group_by { |u| { editor: u.editor_email, klub_id: u.updatable_id } }

    update_groups.each do |key, updates|
      klub = Klub.find(key[:klub_id])

      yield [key[:editor], klub, updates]
    end
  end

  def call

    begin
      groups do |group|
        send_email *group
      end
    rescue Exception => e
      Raygun.track_exception(e)
    end

  end

  def send_email(editor, klub, updates)
    ActiveRecord::Base.logger.info "Sending update accepted emails to #{editor} for klub #{klub.name}"
    klub.send_updates_accepted_notification(editor, updates)

    updates.each do |update|
      update.update_attribute :acceptance_email_sent,  true
    end
  end
end

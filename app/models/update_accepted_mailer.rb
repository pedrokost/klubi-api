#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2016-11-20 14:20:02
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2016-11-27 17:34:46

class UpdateAcceptedMailer

  def self.groups
    update_groups = Update.should_notify.group_by { |u| { editor: u.editor_email, klub_id: u.updatable_id } }

    update_groups.each do |key, updates|
      klub = Klub.find(key[:klub_id])

      yield [key[:editor], klub, updates]
    end
  end

  def self.send_emails
    self.groups do |group|
      self.send_email *group
    end
  end

  def self.send_email(editor, klub, updates)
    klub.send_updates_accepted_notification(editor, updates)

    updates.each do |update|
      update.update_attribute :acceptance_email_sent,  true
    end
  end
end

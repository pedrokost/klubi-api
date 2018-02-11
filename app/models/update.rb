require 'yaml'

class Update < ApplicationRecord
  enum status: {
    unverified: 'unverified',
    accepted:   'accepted',
    rejected:   'rejected',
  }
  belongs_to :updatable, polymorphic: true

  def resolve!
    if status == 'accepted'
      unless updatable.editor_emails.include? editor_email
        updatable.editor_emails << editor_email
      end

      if field == "marked_for_deletion"
        updatable.destroy!
        return
      end

      the_new_value = newvalue
      if field == "categories"
        the_new_value = YAML.load(newvalue).uniq.map(&:parameterize)
      end

      new_attributes = { field => the_new_value }
      if updatable.data_confirmed_at.nil? || self.created_at > updatable.data_confirmed_at
        new_attributes[:data_confirmed_at] = self.created_at
      end
      updatable.update_attributes new_attributes

    end
  end

  def accept!
    accepted!
    resolve!
  end

  def reject!
    rejected!
    resolve!
  end

  def self.should_notify
    Update.where(status: :accepted, acceptance_email_sent: false)
  end
end

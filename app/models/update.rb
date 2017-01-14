require 'yaml'

class Update < ActiveRecord::Base
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

      the_new_value = newvalue
      if field == "categories"
        the_new_value = YAML.load(newvalue).uniq.map(&:parameterize)
      end

      updatable.update_attributes field => the_new_value
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

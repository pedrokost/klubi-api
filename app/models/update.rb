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

      updatable.update_attributes field => newvalue
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

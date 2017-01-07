class AddLastVerificationReminderAtToKlubs < ActiveRecord::Migration
  def change
    add_column :klubs, :last_verification_reminder_at, :datetime, default: nil
  end
end

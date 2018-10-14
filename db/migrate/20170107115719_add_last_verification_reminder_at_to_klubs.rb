class AddLastVerificationReminderAtToKlubs < ActiveRecord::Migration[5.0]
  def change
    add_column :klubs, :last_verification_reminder_at, :datetime, default: nil
  end
end

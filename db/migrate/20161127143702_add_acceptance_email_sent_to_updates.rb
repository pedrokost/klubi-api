class AddAcceptanceEmailSentToUpdates < ActiveRecord::Migration[5.0]
  def change
    add_column :updates, :acceptance_email_sent, :boolean, default: false

    Update.all.each do |update|
      update.acceptance_email_sent = true
      update.save
    end
  end
end

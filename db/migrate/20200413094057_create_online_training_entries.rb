class CreateOnlineTrainingEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :online_training_entries do |t|
      t.string :slug, unique: true
      t.string :title, null: false
      t.string :brief
      t.string :description
      t.string :organizer
      t.string :categories, array: true, default: []
      t.boolean :is_priced

      t.date :terminated_at
      t.boolean :is_verified
      t.datetime :data_confirmed_at
      t.datetime :last_verification_reminder_at
      t.string :data_confirmation_request_hash, unique: true, null: true

      t.timestamps
    end
  end
end

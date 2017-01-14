class CreateEmailStats < ActiveRecord::Migration
  def change
    create_table :email_stats do |t|
      t.string :email, null: false

      t.datetime :last_opened_at
      t.datetime :last_clicked_at
      t.datetime :last_bounced_at
      t.datetime :last_dropped_at
      t.datetime :last_delivered_at

      t.timestamps null: false
    end
    add_index :email_stats, :email, unique: true
  end
end

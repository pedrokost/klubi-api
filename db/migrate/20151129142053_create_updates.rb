class CreateUpdates < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TYPE update_status AS ENUM ('unverified', 'accepted', 'rejected');
    SQL

    create_table :updates do |t|
      t.string :updatable_type, null: false, index: true
      t.integer :updatable_id, null: false, index: true
      t.string :field, null: false
      t.string :oldvalue
      t.string :newvalue
      t.column :status, :update_status, default: 'unverified', index: true
      t.string :editor_email
      t.timestamps null: false
    end
  end

  def down
    drop_table :updates

    execute <<-SQL
      DROP TYPE update_status;
    SQL
  end
end

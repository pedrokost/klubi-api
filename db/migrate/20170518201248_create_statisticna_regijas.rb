class CreateStatisticnaRegijas < ActiveRecord::Migration[5.0]
  def change
    create_table :statisticna_regijas do |t|
      t.string :name, null: false
      t.string :slug, null: false, unique: true
      t.integer :population_size
      t.multi_polygon :geom, geographic: true

      t.timestamps null: false
    end

    add_index :statisticna_regijas, :geom, using: :gist
    add_index :statisticna_regijas, :slug, :unique => true
  end
end

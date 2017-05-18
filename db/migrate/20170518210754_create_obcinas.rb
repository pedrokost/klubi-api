class CreateObcinas < ActiveRecord::Migration
  def change
    create_table :obcinas do |t|
      t.string :name, null: false
      t.string :slug, null: false, unique: true
      t.integer :population_size
      t.multi_polygon :geom, geographic: true
      t.references :statisticna_regija, index: true

      t.timestamps null: false
    end

    add_index :obcinas, :geom, using: :gist
    add_index :obcinas, :slug, :unique => true
    add_foreign_key :obcinas, :statisticna_regijas, column: :statisticna_regija_id
  end
end

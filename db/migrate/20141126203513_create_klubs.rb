class CreateKlubs < ActiveRecord::Migration
	def change
		create_table :klubs do |t|
			t.string :name
			t.string :slug
			t.string :address
			t.string :town
			t.string :website
			t.string :phone
			t.string :email
			t.string :editor_email
			t.decimal :latitude, precision: 10, scale: 6
			t.decimal :longitude, precision: 10, scale: 6
			t.timestamps
		end
	end
end

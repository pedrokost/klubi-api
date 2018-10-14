class AddCompleteToKlubs < ActiveRecord::Migration[5.0]
  def change
  	add_column :klubs, :complete, :boolean, default: false
  end
end

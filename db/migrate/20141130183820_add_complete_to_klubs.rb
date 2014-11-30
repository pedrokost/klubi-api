class AddCompleteToKlubs < ActiveRecord::Migration
  def change
  	add_column :klubs, :complete, :boolean, default: false
  end
end

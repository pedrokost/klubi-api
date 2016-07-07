class AddNotesToKlubs < ActiveRecord::Migration
  def change
    add_column :klubs, :notes, :string
  end
end

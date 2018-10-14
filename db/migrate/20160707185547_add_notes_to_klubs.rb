class AddNotesToKlubs < ActiveRecord::Migration[5.0]
  def change
    add_column :klubs, :notes, :string
  end
end

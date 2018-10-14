class AddCategoriesToKlubs < ActiveRecord::Migration[5.0]
  def change
    add_column :klubs, :categories, :string, array: true, default: []
    add_index  :klubs, :categories, using: 'gin'
  end
end

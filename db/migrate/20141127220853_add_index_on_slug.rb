class AddIndexOnSlug < ActiveRecord::Migration[5.0]
  def change
  	add_index :klubs, :slug
  end
end

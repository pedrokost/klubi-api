class AddIndexOnSlug < ActiveRecord::Migration
  def change
  	add_index :klubs, :slug
  end
end

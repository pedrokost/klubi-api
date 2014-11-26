class MakeNameAndSlugNotNull < ActiveRecord::Migration
  def change
  	change_column :klubs, :name, :string, null: false
  	change_column :klubs, :slug, :string, null: false
  end
end

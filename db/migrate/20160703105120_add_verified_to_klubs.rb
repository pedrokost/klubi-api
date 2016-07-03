class AddVerifiedToKlubs < ActiveRecord::Migration
  def change
    add_column :klubs, :verified, :boolean, default: false
  end
end

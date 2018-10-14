class AddVerifiedToKlubs < ActiveRecord::Migration[5.0]
  def change
    add_column :klubs, :verified, :boolean, default: false
  end
end

class AddClosedAtToKlubs < ActiveRecord::Migration
  def change
    add_column :klubs, :closed_at, :date, default: nil
  end
end

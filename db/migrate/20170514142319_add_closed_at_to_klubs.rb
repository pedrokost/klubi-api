class AddClosedAtToKlubs < ActiveRecord::Migration[5.0]
  def change
    add_column :klubs, :closed_at, :date, default: nil
  end
end

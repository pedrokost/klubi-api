class AddDataConfirmedAtToKlubs < ActiveRecord::Migration[5.1]
  def change
    add_column :klubs, :data_confirmed_at, :datetime, default: nil
  end
end

class AddVisitsCountAndVisitsCountUpdatedAtToKlubs < ActiveRecord::Migration[5.1]
  def change
    add_column :klubs, :visits_count, :integer, default: 0
    add_column :klubs, :visits_count_updated_at, :datetime, default: nil
  end
end

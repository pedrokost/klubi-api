class AddParentRefToKlub < ActiveRecord::Migration[5.0]
  def change
    add_reference :klubs, :parent, index: true
  end
end

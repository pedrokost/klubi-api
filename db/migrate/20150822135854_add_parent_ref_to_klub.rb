class AddParentRefToKlub < ActiveRecord::Migration
  def change
    add_reference :klubs, :parent, index: true
  end
end

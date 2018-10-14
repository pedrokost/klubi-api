class AddFacebookUrlToKlubs < ActiveRecord::Migration[5.0]
  def change
    add_column :klubs, :facebook_url, :string
  end
end

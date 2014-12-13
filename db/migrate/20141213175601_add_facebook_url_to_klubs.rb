class AddFacebookUrlToKlubs < ActiveRecord::Migration
  def change
    add_column :klubs, :facebook_url, :string
  end
end

class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.references :commentable, polymorphic: true, index: true
      t.string :body
      t.string :commenter_email
      t.string :commenter_name

      t.timestamps
    end
  end
end

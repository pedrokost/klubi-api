class AllowMultipleEditors < ActiveRecord::Migration[5.0]
  def change
    remove_column :klubs, :editor_email
    add_column :klubs, :editor_emails, :string, array: true, default: []
    add_index  :klubs, :editor_emails, using: 'gin'
  end
end

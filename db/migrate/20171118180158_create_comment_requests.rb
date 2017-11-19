class CreateCommentRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :comment_requests do |t|
      t.references :commentable, polymorphic: true
      t.string :requester_email
      t.string :requester_name
      t.string :commenter_email
      t.string :commenter_name
      t.string :request_hash, index: true
      t.references :comment, index: true, null: true

      t.timestamps
    end
    add_index :comment_requests, [:commentable_type, :commentable_id, :commenter_email], unique: true, name: 'index_comment_request_unique_commenter_commentable'
  end
end

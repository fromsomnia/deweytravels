class AddSocialCastUserId < ActiveRecord::Migration
  def change
    add_column :users, :sc_user_id, :string
    add_index :users, :sc_user_id
  end
end

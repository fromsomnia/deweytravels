class AddGoogleAuthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :goog_access_token, :string
    add_column :users, :goog_expires_time, :int
  end
end

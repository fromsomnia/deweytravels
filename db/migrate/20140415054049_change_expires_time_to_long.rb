class ChangeExpiresTimeToLong < ActiveRecord::Migration
  def change
    change_column :users, :goog_expires_time, :integer, :limit => 8
  end
end

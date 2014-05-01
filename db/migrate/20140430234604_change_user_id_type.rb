class ChangeUserIdType < ActiveRecord::Migration
  def change
    change_column :users, :fb_id, :int, :limit => 8
  end
end

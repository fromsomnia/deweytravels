class RenameScidToFbuid < ActiveRecord::Migration
  def change
  	rename_column :users, :sc_user_id, :fb_id
  end
end

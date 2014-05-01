class RemoveCompanyInfoFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :department
    remove_column :users, :position
    remove_column :users, :goog_access_token
    remove_column :users, :goog_expires_time
  end
end

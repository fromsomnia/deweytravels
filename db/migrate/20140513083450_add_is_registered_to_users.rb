class AddIsRegisteredToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_registered, :boolean, :default => false
  end
end

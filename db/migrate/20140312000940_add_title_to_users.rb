class AddTitleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :title, :string
    remove_column :users, :sc_user_id
    add_column :users, :sc_user_id, :integer
  end
end

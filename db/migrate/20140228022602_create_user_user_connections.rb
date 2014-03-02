class CreateUserUserConnections < ActiveRecord::Migration
  def change
    create_table :user_user_connections do |t|

      t.column :superior_id, :integer
      t.column :subordinate_id, :integer
      
    end
  end
end

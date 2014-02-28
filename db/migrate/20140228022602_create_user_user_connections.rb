class CreateUserUserConnections < ActiveRecord::Migration
  def change
    create_table :user_user_connections do |t|

      t.timestamps
    end
  end
end

class CreateTopicUserConnections < ActiveRecord::Migration
  def change
    create_table :topic_user_connections do |t|

      t.column :user_id, :integer
      t.column :topic_id, :integer
      
    end
  end
end

class CreateTopicUserConnections < ActiveRecord::Migration
  def change
    create_table :topic_user_connections do |t|

      t.timestamps
    end
  end
end

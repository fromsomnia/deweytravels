class CreateTopicTopicConnections < ActiveRecord::Migration
  def change
    create_table :topic_topic_connections do |t|

      t.timestamps
    end
  end
end

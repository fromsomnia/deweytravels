class CreateTopicTopicConnections < ActiveRecord::Migration
  def change
    create_table :topic_topic_connections do |t|

      t.column :subtopic_id, :integer
      t.column :supertopic_id, :integer
      
    end
  end
end

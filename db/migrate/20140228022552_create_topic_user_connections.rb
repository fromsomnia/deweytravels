class CreateTopicUserConnections < ActiveRecord::Migration
  def change
    create_table :topic_user_connections do |t|

      t.column :expert_id, :integer
      t.column :expertise_id, :integer
      
    end
  end
end

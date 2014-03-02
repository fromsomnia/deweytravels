class CreateGraphsTopics < ActiveRecord::Migration
  def change
    create_table :graphs_topics, :id => false do |t|

    	t.column :graph_id, :integer
    	t.column :topic_id, :integer

    end
  end
end

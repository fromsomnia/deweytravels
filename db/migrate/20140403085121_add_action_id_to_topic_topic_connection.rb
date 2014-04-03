class AddActionIdToTopicTopicConnection < ActiveRecord::Migration
  def change
    add_column :topic_topic_connections, :action_id, :integer
  end
end

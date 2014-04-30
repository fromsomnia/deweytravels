class RemoveVoting < ActiveRecord::Migration
  def change
    drop_table :actions
    drop_table :user_action_votes
    remove_column :topic_topic_connections, :action_id
  end
end

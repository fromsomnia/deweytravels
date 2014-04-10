class AddUniqueConstraintsToTopic < ActiveRecord::Migration
  def change
    add_index :topics, [:graph_id, :title], :unique => true
  end
end

class AddUserAndTopicToGraph < ActiveRecord::Migration
  def change
    add_reference :users, :graph, index: true
    add_reference :topics, :graph, index: true
  end
end

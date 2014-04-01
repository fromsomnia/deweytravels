class AddImageAndFreebaseTopicToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :image_url, :string
    add_column :topics, :freebase_topic_id, :string
  end
end

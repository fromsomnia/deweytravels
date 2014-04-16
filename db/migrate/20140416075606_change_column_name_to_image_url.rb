class ChangeColumnNameToImageUrl < ActiveRecord::Migration
  def change
    rename_column :topics, :freebase_image_url, :image_url
    remove_column :topics, :freebase_topic_id
  end
end

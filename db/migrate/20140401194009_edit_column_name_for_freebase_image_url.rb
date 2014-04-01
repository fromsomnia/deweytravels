class EditColumnNameForFreebaseImageUrl < ActiveRecord::Migration
  def change
    rename_column :topics, :image_url, :freebase_image_url
  end
end

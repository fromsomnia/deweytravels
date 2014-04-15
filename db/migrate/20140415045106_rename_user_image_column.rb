class RenameUserImageColumn < ActiveRecord::Migration
  def change
    rename_column :users, :image_30, :image_url
    remove_column :users, :image_16
    remove_column :users, :image_70
    remove_column :users, :image_140
    remove_column :users, :image
  end
end

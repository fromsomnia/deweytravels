class AddFreebaseIdToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :freebase_id, :string
  end
end

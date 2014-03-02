class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
    	
    	t.column :title, :string

    end
  end
end

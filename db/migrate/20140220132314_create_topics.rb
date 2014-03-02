class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
    	
    	t.column :title, :string

    	t.column :expertise_id, :integer
    	t.column :subtopic_id, :integer
    	t.column :supertopic_id, :integer
    end
  end
end

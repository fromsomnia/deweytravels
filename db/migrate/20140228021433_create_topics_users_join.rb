class CreateTopicsUsersJoin < ActiveRecord::Migration
  def change
    create_table :topics_users, :id => false do |t|

    	t.column :expertise_id, :integer
    	t.column :expert_id, :integer
    	
    end
  end
end

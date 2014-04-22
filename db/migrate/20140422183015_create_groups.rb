class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|

    	t.column :title, :string
    	t.column :description, :string
    	t.column :user_id, :integer

    end
  end
end

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.column :first_name, :string
    	t.column :last_name, :string
    	t.column :email, :string
    	t.column :username, :string
    	t.column :password, :string
    	t.column :position, :string
    	t.column :department, :string
    	t.column :image, :string

    	t.column :expert_id, :integer
    	t.column :superior_id, :integer
    	t.column :subordinate_id, :integer
    	t.column :peer_id, :integer
    	t.column :connection_subordinate, :integer
    	t.column :connection_superior, :integer
    	t.column :connection_expert, :integer
    end
  end
end

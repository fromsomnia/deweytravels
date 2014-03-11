class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, id: false do |t|
        t.column :user_id, :primary_key
    	t.column :first_name, :string
    	t.column :last_name, :string
    	t.column :email, :string
        t.column :office_phone, :integer
    	t.column :username, :string
    	t.column :password, :string
        t.column :domain, :string
    	t.column :title, :string
    	t.column :department, :string
        t.column :image_16, :string
        t.column :image_30, :string
        t.column :image_70, :string
        t.column :image_140, :string
    end
  end
end

class AddUniqueConstraintsToDomain < ActiveRecord::Migration
  def change
    add_index :graphs, :domain, :unique => true
    add_index :users, :email, :unique => true

    remove_column :users, :domain, :string
    drop_table :graphs_topics
  end
end

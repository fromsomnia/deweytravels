class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.integer :table_pkey
      t.integer :good_vote
      t.integer :total_vote
      t.string :type

      t.timestamps
    end
  end
end

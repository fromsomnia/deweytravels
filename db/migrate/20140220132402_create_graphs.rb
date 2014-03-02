class CreateGraphs < ActiveRecord::Migration
  def change
    create_table :graphs do |t|

      t.column :title, :string
      
    end
  end
end

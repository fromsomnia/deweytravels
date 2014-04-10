class AddDomainNameToGraphs < ActiveRecord::Migration
  def change
    rename_column :graphs, :title, :domain
  end
end

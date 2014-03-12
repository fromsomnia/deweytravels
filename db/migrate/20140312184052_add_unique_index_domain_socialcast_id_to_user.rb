class AddUniqueIndexDomainSocialcastIdToUser < ActiveRecord::Migration
  def change
    add_index :users, [:sc_user_id, :domain], :unique => true
  end
end

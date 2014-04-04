class CreateUserActionVotes < ActiveRecord::Migration
  def change
    create_table :user_action_votes do |t|
      t.belongs_to :action
      t.belongs_to :user
    end
  end
end

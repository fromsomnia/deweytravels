class AddVoteToUserActionVotes < ActiveRecord::Migration
  def change
    add_column :user_action_votes, :vote_value, :integer
    add_timestamps :user_action_votes

    remove_column :actions, :good_vote
    remove_column :actions, :total_vote
  end
end

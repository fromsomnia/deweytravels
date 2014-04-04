class UserActionVote < ActiveRecord::Base
  belongs_to :action, :class_name => "Action"
  belongs_to :user, :class_name => "User"
  
end

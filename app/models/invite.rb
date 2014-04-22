class Invite < ActiveRecord::Base
  belongs_to :inviter, :class_name => "User"

  # TODO: check this when the Group class is added.
  belongs_to :group
end

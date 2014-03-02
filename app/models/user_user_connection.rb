class UserUserConnection < ActiveRecord::Base
	# attr_accessible :

	belongs_to :superior, :class_name => "User"
	belongs_to :subordinate, :class_name => "User"s

end

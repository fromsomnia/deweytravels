class User < ActiveRecord::Base
	# attr_accessible :

	has_and_belongs_to_many :expertises, :class_name => "Topic", :foreign_key => "expert_id"

	has_many :subordinates, :class_name => "User", :foreign_key => "superior_id"
	has_many :superiors, :class_name => "User", :foreign_key => "subordinate_id"
	has_many :peers, :class_name => "User", :foreign_key => "peer_id"

	belongs_to :superior, :class_name => "User"
	belongs_to :peer, :class_name => "User"
	belongs_to :subordiante, :class_name => "User"

	belongs_to :connection_subordinate, :class_name => "Connection"
	belongs_to :connection_superior, :class_name => "Connection"
	belongs_to :connection_expert, :class_name => "Connection"

end

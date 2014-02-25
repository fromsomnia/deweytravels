class User < ActiveRecord::Base
	attr_accessible :

	has_many :from_users, :class_name => "User", :foreign_key => "from_user_id"
	has_many :to_users, :class_name => "User", :foreign_key => "to_user_id"

	has_many :users, :through =>
	belongs

	belongs_to :from_user, :class_name => "User"
	belongs_to :to_user, :class_name => "User"
end

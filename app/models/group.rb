class Group < ActiveRecord::Base
	attr_accessible :title, :description, :creator_id

	has_and_belongs_to_many :users

end

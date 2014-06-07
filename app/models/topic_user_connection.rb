# == Schema Information
#
# Table name: topic_user_connections
#
#  id           :integer          not null, primary key
#  expert_id    :integer
#  expertise_id :integer
#

# Connection class between topics and users - the 'experts-expertise' relationship
class TopicUserConnection < ActiveRecord::Base
	# attr_accessible :

	belongs_to :expert, :class_name => "User"
	belongs_to :expertise, :class_name => "Topic"

  validate :in_same_graph, on: :create

  # Returns true if the two nodes involved are in the same graph.
  def in_same_graph
    if expert.graph.id != expertise.graph.id
      errors.add(:expert,  "should be in the same graph with the expertise")
    end
  end

  def graph
    expert.graph
  end
end

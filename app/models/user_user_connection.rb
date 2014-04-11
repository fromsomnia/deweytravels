class UserUserConnection < ActiveRecord::Base
	# attr_accessible :

	belongs_to :superior, :class_name => "User"
	belongs_to :subordinate, :class_name => "User"

  validate :in_same_graph, on: :create

  def in_same_graph
    if superior.graph.id != subordinate.graph.id
      errors.add(:superior,  "should be in the same graph with the subordinate")
    end
  end

  def graph
    superior.graph
  end

  def action_class
    AddUserUserConnectionAction
  end
  include ActionableObject
end

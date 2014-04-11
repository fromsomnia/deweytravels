class Action < ActiveRecord::Base
  # Actions are operations on the site that can be reverted and voted on
  # by users. This abstractions make it easy to create new reversible
  # and votable operations.

  # When an action reached below a certain threshold, that action
  # will be automatically be reverted by the system.

  has_many :user_action_votes, :foreign_key => "action_id"
  has_many :voters, :through => :user_action_votes, :source => :user

  attr_accessible :table_pkey
  class_attribute :action_object_class
  THRESHOLD = 0.5

  def _voted_by(user, vote_value)
    vote = UserActionVote.find_by_user_id_and_action_id(user.id, self.id)
    if (!vote)
      vote = UserActionVote.new
      vote.user_id = user.id
      vote.action_id = self.id
    end
    vote.vote_value = vote_value
    vote.save
  end

  def is_upvoted_by?(user)
    vote = UserActionVote.find_by_user_id_and_action_id(user.id, self.id)
    (vote && vote.vote_value == 1)
  end

  def is_downvoted_by?(user)
    vote = UserActionVote.find_by_user_id_and_action_id(user.id, self.id)
    (vote && vote.vote_value == -1)
  end

  def upvoted_by(user)
    self._voted_by(user, 1)
  end

  def downvoted_by(user)
    self._voted_by(user, -1)
  end

  def score
    if self.voters.count > 0
      self.voters.sum(:vote_value) / self.voters.count
    else
      0
    end
  end

  # The actionable object that is represented by this action
  def actionable_object
    object_class = self.action_object_class
    object_class.find(self.table_pkey)
  end

  def revert
    self.object.destroy
    self.destroy
  end

  # What object does the action?
  def subject
    raise "Subclass should implement"
  end

  def action_text
    raise "Subclass should implement"
  end

  # What object does the subject does this action to?
  def recipient
    raise "Subclass should implement"
  end
end

module ActionableObject
  # ActionableObject is an interface abstraction. Simply add
  # include ActionableObject to the model class that you want to be
  # votable.

  # example:
  # "TopicTopicConnection" is an "ActionableObject", where the "Action"
  # is "AddTopicTopicConnection".
  # In addition to including ActionableObject,
  # it should also specify action_class.

  # See TopicTopicConnection for example.

  extend ActiveSupport::Concern

  included do
    after_save :add_action
  end

  def action
    current_action = self.action_class.find_by table_pkey: self.id
    if not current_action
      current_action = self.add_action
    end
    current_action
  end

  def is_upvoted_by?(user)
    self.action.is_upvoted_by?(user)
  end

  def is_downvoted_by?(user)
    self.action.is_downvoted_by?(user)
  end

  def downvoted_by(user)
    if user.graph == self.graph
      self.action.downvoted_by(user)
    end
  end

  def upvoted_by(user)
    if user.graph == self.graph
      self.action.upvoted_by(user)
    end
  end

  def add_action
    new_action = self.action_class.new
    new_action.table_pkey = self.id
    new_action.save
    new_action
  end
end


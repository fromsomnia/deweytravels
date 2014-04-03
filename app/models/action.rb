class Action < ActiveRecord::Base
  # Actions are operations on the site that can be reverted and voted on
  # by users. This abstractions make it easy to create new reversible
  # and votable operations.

  # When an action reached below a certain threshold, that action
  # will be automatically be reverted by the system.

  attr_accessible :table_pkey
  class_attribute :action_object_class
  THRESHOLD = 0.5

  def upvote
    @good_vote += 1
    @all_vote += 1
  end

  def downvote
    @all_vote += 1
    if score < THRESHOLD
      self.revert
    end
  end

  def score
    @good_vote / @all_vote
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
  extend ActiveSupport::Concern

  included do
    after_save :add_action
  end

  def action
    self.action_class.find_by table_pkey: self.id
  end

  def add_action
    new_action = self.action_class.new
    new_action.table_pkey = self.id
    new_action.save
  end
end


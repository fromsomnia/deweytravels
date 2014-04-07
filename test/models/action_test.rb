require 'test_helper'

class ActionTest < ActiveSupport::TestCase
  def create_action
    topic1 = Topic.all.first
    topic2 = Topic.all.last
    topic1.subtopics << topic2

    conn = TopicTopicConnection.find_by subtopic_id: topic2.id, supertopic_id:topic1.id
    return conn.action
  end

  test "basic test" do
    action = self.create_action
    user = User.first
    assert !action.is_upvoted_by?(user)
    assert !action.is_downvoted_by?(user)
    assert_equal(0, action.voters.count)
    assert_equal(0, action.score)

    action.upvoted_by(user)
    assert action.is_upvoted_by?(user)
    assert !action.is_downvoted_by?(user)
    assert_equal(1, action.voters.count)
    assert_equal(1, action.score)

    action.downvoted_by(user)
    assert !action.is_upvoted_by?(user)
    assert action.is_downvoted_by?(user)
    assert_equal(-1, action.score)

    user2 = User.last
    action.upvoted_by(user2)
    assert !action.is_upvoted_by?(user)
    assert action.is_upvoted_by?(user2)
    assert_equal(0, action.score)
  end

end

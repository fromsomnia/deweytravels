require 'test_helper'

class UserActionTest < ActiveSupport::TestCase
  def create_action
    topic1 = Topic.all.first
    topic2 = Topic.all.last
    topic1.subtopics << topic2

    conn = TopicTopicConnection.find_by subtopic_id: topic2.id, supertopic_id:topic1.id
    return conn.action
  end

  test "test_vote" do
    action = self.create_action
    user = User.first

    assert_equal(0, UserActionVote.all.count)
    assert_equal(0, action.voters.count)
    action.upvoted_by(user)
    assert_equal(1, action.voters.count)
    assert_equal(1, action.score)
    assert_equal(1, UserActionVote.all.count)

    action.downvoted_by(user)

    assert_equal(1, UserActionVote.all.count)
    assert_equal(1, action.voters.count)
    assert_equal(-1, action.score)

    user2 = User.last
    action.upvoted_by(user2)
    assert_equal(2, UserActionVote.all.count)
    assert_equal(2, action.voters.count)
    assert_equal(0, action.score)
  end

end

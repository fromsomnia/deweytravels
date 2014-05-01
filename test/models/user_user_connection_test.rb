require 'test_helper'

class UserUserConnectionTest < ActiveSupport::TestCase

  test "check_validation" do
    new_graph = Graph.new
    new_graph.domain = "new domain"
    new_graph.save

    user1 = User.all.first

    user2 = User.all.last
    user2.graph = new_graph
    user2.save

    assert_raise ActiveRecord::RecordInvalid do
      user1.subordinates << user2
    end

  end
end

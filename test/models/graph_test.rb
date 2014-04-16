require 'test_helper'

class GraphTest < ActiveSupport::TestCase

  test "test_search" do
    graph = Graph.find_by_domain("fixtures")

    results = graph.search("john")
    assert_equal(1, results.length)
    assert_equal('user', results[0]["type"])

    # Check for case sensitivity
    results = graph.search("John")
    assert_equal(1, results.length)
    assert_equal('user', results[0]["type"])

    # Should still work if it's a substring, not a
    # complete word.

    results = graph.search("joh")
    assert_equal(2, results.length)
    assert_equal('user', results[0]["type"])
    assert_equal('user', results[1]["type"])

    # Should still work if it's a substring of the second word

    results = graph.search("pulv")
    assert_equal(1, results.length)
    assert_equal('user', results[0]["type"])

    # If the matching substring is in not
    # in front of the word, it's not a match.

    results = graph.search("ohn")
    assert_equal(0, results.length)


    # Try for topics
    results = graph.search("c++")
    assert_equal(1, results.length)
    assert_equal('topic', results[0]["type"])
  end
end

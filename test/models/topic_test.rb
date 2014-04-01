require 'test_helper'

class TopicTest < ActiveSupport::TestCase

  test "scrape_image_from_freebase" do
    new_topic = Topic.new
    new_topic.title = "The Beatles"
    new_topic.save
    assert_nil(new_topic.freebase_topic_id)
    assert_equal("/assets/picture_placeholder.png", new_topic.image_url)

    new_topic.scrape_image_from_freebase

    assert new_topic.freebase_topic_id
    assert new_topic.image_url
    assert_equal("/m/07c0j", new_topic.freebase_topic_id)
    assert_equal("https://usercontent.googleapis.com/freebase/v1/image/m/04y0q3q?maxwidth=225&maxheight=225&mode=fillcropmid",
                 new_topic.image_url)


    # If Freebase doesn't give an image, then we should default to placeholder.
    new_topic = Topic.new
    new_topic.title = "aer9a7e0r9audfaia;svacvaeirha0eir"
    new_topic.save

    new_topic.scrape_image_from_freebase

    assert_nil(new_topic.freebase_topic_id)
    assert_equal("/assets/picture_placeholder.png", new_topic.image_url)
  end
end

class PopulateTopicHierarchy < ActiveRecord::Migration
  def change
	topic = Topic.find_by_title("full-stack")
	  topic.subtopics << Topic.find_by_title("web")

	topic = Topic.find_by_title("programming")
	  topic.subtopics << Topic.find_by_title("full-stack")

	topic = Topic.find_by_title("mobile")
	  topic.subtopics << Topic.find_by_title("iOS")

	topic = Topic.find_by_title("mobile")
	  topic.subtopics << Topic.find_by_title("android")

	topic = Topic.find_by_title("programming")
	  topic.subtopics << Topic.find_by_title("mobile")

	topic = Topic.find_by_title("mobile")
	  topic.subtopics << Topic.find_by_title("objective c")

	topic = Topic.find_by_title("mobile")
	  topic.subtopics << Topic.find_by_title("java")

	topic = Topic.find_by_title("web")
	  topic.subtopics << Topic.find_by_title("ruby")

	topic = Topic.find_by_title("web")
	  topic.subtopics << Topic.find_by_title("rails")

	topic = Topic.find_by_title("web")
	  topic.subtopics << Topic.find_by_title("javascript")

	topic = Topic.find_by_title("web")
	  topic.subtopics << Topic.find_by_title("php")

	topic = Topic.find_by_title("web")
	  topic.subtopics << Topic.find_by_title("python")

	topic = Topic.find_by_title("version control")
	  topic.subtopics << Topic.find_by_title("git")

	topic = Topic.find_by_title("version control")
	  topic.subtopics << Topic.find_by_title("subversion")

	topic = Topic.find_by_title("web")
	  topic.subtopics << Topic.find_by_title("jquery")

	topic = Topic.find_by_title("programming")
	  topic.subtopics << Topic.find_by_title("user growth")

	topic = Topic.find_by_title("programming")
	  topic.subtopics << Topic.find_by_title("algorithms")

	topic = Topic.find_by_title("programming")
	  topic.subtopics << Topic.find_by_title("fortran")

	topic = Topic.find_by_title("programming")
	  topic.subtopics << Topic.find_by_title("java")

	topic = Topic.find_by_title("programming")
	  topic.subtopics << Topic.find_by_title("ruby")

	topic = Topic.find_by_title("programming")
	  topic.subtopics << Topic.find_by_title("c")

	topic = Topic.find_by_title("programming")
	  topic.subtopics << Topic.find_by_title("c++")

	topic = Topic.find_by_title("programming")
	  topic.subtopics << Topic.find_by_title("objective c")

	topic = Topic.find_by_title("web")
	  topic.subtopics << Topic.find_by_title("html")

	topic = Topic.find_by_title("sales")
	  topic.subtopics << Topic.find_by_title("statistics")

	topic = Topic.find_by_title("management")
	  topic.subtopics << Topic.find_by_title("presentation")

	topic = Topic.find_by_title("management")
	  topic.subtopics << Topic.find_by_title("communication")

	topic = Topic.find_by_title("programming")
	  topic.subtopics << Topic.find_by_title("graphic design")

	topic = Topic.find_by_title("programming")
	  topic.subtopics << Topic.find_by_title("data visualization")
  end
end

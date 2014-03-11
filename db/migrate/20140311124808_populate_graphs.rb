class PopulateGraphs < ActiveRecord::Migration
  def change
	full_stack = Graph.new(
	 :title => "full_stack")
	full_stack.save(:validate => false)
	array = ["web", "javascript", "ruby", "python", "rails", "php", "version_control", "html", "jquery", "git", "subversion", "data_visualization", "graphic_design"]
	array.each do |topic|
		full_stack.topics << Topic.find_by_title(topic)
	end

	programming = Graph.new(
	 :title => "programming")
	programming.save(:validate => false)
	array = ["mobile", "iOS", "android", "algorithms", "ruby", "python", "fortran", "java", "c", "c_plus_plus", "objective_c", "subersion", "git", "version_control"]
	array.each do |topic|
		programming.topics << Topic.find_by_title(topic)
	end

	web = Graph.new(
	 :title => "web")
	web.save(:validate => false)
	array = ["javascript", "ruby", "python", "php", "rails", "html", "jquery"]
	array.each do |topic|
		web.topics << Topic.find_by_title(topic)
	end 

	mobile = Graph.new(
	 :title => "mobile")
	mobile.save(:validate => false)
	array = ["iOS", "android", "objective_c"]
	array.each do |topic|
		mobile.topics << Topic.find_by_title(topic)
	end

	business = Graph.new(
	 :title => "business")
	business.save(:validate => false)
	array = ["sales", "communication", "presentation", "management"]
	array.each do |topic|
		business.topics << Topic.find_by_title(topic)
	end
  end
end

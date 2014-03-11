class PopulateTopics < ActiveRecord::Migration
  def change
	full_stack = Topic.new(
	 :title => "full-stack")
	full_stack.save(:validate => false)

	web = Topic.new(
	 :title => "web")
	web.save(:validate => false)

	programming = Topic.new(
	 :title => "programming")
	programming.save(:validate => false)

	iOS = Topic.new(
	 :title => "iOS")
	iOS.save(:validate => false)

	user_growth = Topic.new(
	 :title => "user growth")
	user_growth.save(:validate => false)

	algorithms = Topic.new(
	 :title => "algorithms")
	algorithms.save(:validate => false)

	javascript = Topic.new(
	 :title => "javascript")
	javascript.save(:validate => false)

	ruby = Topic.new(
	 :title => "ruby")
	ruby.save(:validate => false)

	python = Topic.new(
	 :title => "python")
	python.save(:validate => false)

	fortran = Topic.new(
	 :title => "fortran")
	fortran.save(:validate => false)

	java = Topic.new(
	 :title => "java")
	java.save(:validate => false)

	rails = Topic.new(
	 :title => "rails")
	rails.save(:validate => false)

	php = Topic.new(
	 :title => "php")
	php.save(:validate => false)

	android = Topic.new(
	 :title => "android")
	android.save(:validate => false)

	c = Topic.new(
	 :title => "c")
	c.save(:validate => false)

	c_plus_plus = Topic.new(
	 :title => "c++")
	c_plus_plus.save(:validate => false)

	objective_c = Topic.new(
	 :title => "objective c")
	objective_c.save(:validate => false)

	git = Topic.new(
	 :title => "git")
	git.save(:validate => false)

	subversion = Topic.new(
	 :title => "subversion")
	subversion.save(:validate => false)

	version_control = Topic.new(
	 :title => "version control")
	version_control.save(:validate => false)

	html = Topic.new(
	 :title => "html")
	html.save(:validate => false)

	jquery = Topic.new(
	 :title => "jquery")
	jquery.save(:validate => false)

	mobile = Topic.new(
	 :title => "mobile")
	mobile.save(:validate => false)

	management = Topic.new(
	 :title => "management")
	management.save(:validate => false)

	statistics = Topic.new(
	 :title => "statistics")
	statistics.save(:validate => false)

	sales = Topic.new(
	 :title => "sales")
	sales.save(:validate => false)

	graphic_design = Topic.new(
	 :title => "graphic design")
	graphic_design.save(:validate => false)

	presentation = Topic.new(
	 :title => "presentation")
	presentation.save(:validate => false)

	communication = Topic.new(
	 :title => "communication")
	communication.save(:validate => false)

	data_visualization = Topic.new(
	 :title => "data visualization")
	data_visualization.save(:validate => false)
  end
end

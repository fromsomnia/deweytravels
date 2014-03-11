class PopulateUserTopicConnections < ActiveRecord::Migration
  def change
	 expert = User.find_by_first_name("William")
	 expert.expertises << Topic.find_by_title("full-stack")

	 expert = User.find_by_first_name("William")
	 expert.expertises << Topic.find_by_title("web")

	 expert = User.find_by_first_name("William")
	 expert.expertises << Topic.find_by_title("programming")

	 expert = User.find_by_first_name("William")
	 expert.expertises << Topic.find_by_title("iOS")

	 expert = User.find_by_first_name("William")
	 expert.expertises << Topic.find_by_title("rails")

	 expert = User.find_by_first_name("William")
	 expert.expertises << Topic.find_by_title("java")

	 expert = User.find_by_first_name("William")
	 expert.expertises << Topic.find_by_title("html")

	 expert = User.find_by_first_name("William")
	 expert.expertises << Topic.find_by_title("mobile")

	 expert = User.find_by_first_name("William")
	 expert.expertises << Topic.find_by_title("javascript")

	 expert = User.find_by_first_name("William")
	 expert.expertises << Topic.find_by_title("jquery")

	 expert = User.find_by_first_name("Veni")
	 expert.expertises << Topic.find_by_title("full-stack")

	 expert = User.find_by_first_name("Veni")
	 expert.expertises << Topic.find_by_title("web")

	 expert = User.find_by_first_name("Veni")
	 expert.expertises << Topic.find_by_title("programming")

	 expert = User.find_by_first_name("Veni")
	 expert.expertises << Topic.find_by_title("python")

	 expert = User.find_by_first_name("Veni")
	 expert.expertises << Topic.find_by_title("management")

	 expert = User.find_by_first_name("Veni")
	 expert.expertises << Topic.find_by_title("android")

	 expert = User.find_by_first_name("Veni")
	 expert.expertises << Topic.find_by_title("html")

	 expert = User.find_by_first_name("Veni")
	 expert.expertises << Topic.find_by_title("mobile")

	 expert = User.find_by_first_name("Veni")
	 expert.expertises << Topic.find_by_title("version control")

	 expert = User.find_by_first_name("Veni")
	 expert.expertises << Topic.find_by_title("subversion")

	 expert = User.find_by_first_name("Veni")
	 expert.expertises << Topic.find_by_title("git")

	 expert = User.find_by_first_name("Veni")
	 expert.expertises << Topic.find_by_title("communication")

	 expert = User.find_by_first_name("Brett")
	 expert.expertises << Topic.find_by_title("full-stack")

	 expert = User.find_by_first_name("Brett")
	 expert.expertises << Topic.find_by_title("web")

	 expert = User.find_by_first_name("Brett")
	 expert.expertises << Topic.find_by_title("programming")

	 expert = User.find_by_first_name("Brett")
	 expert.expertises << Topic.find_by_title("iOS")

	 expert = User.find_by_first_name("Brett")
	 expert.expertises << Topic.find_by_title("c++")

	 expert = User.find_by_first_name("Brett")
	 expert.expertises << Topic.find_by_title("java")

	 expert = User.find_by_first_name("Brett")
	 expert.expertises << Topic.find_by_title("html")

	 expert = User.find_by_first_name("Brett")
	 expert.expertises << Topic.find_by_title("mobile")

	 expert = User.find_by_first_name("Brett")
	 expert.expertises << Topic.find_by_title("algorithms")

	 expert = User.find_by_first_name("Brett")
	 expert.expertises << Topic.find_by_title("presentation")

	 expert = User.find_by_first_name("Brett")
	 expert.expertises << Topic.find_by_title("management")

	 expert = User.find_by_first_name("John")
	 expert.expertises << Topic.find_by_title("full-stack")

	 expert = User.find_by_first_name("John")
	 expert.expertises << Topic.find_by_title("web")

	 expert = User.find_by_first_name("John")
	 expert.expertises << Topic.find_by_title("programming")

	 expert = User.find_by_first_name("John")
	 expert.expertises << Topic.find_by_title("graphic design")

	 expert = User.find_by_first_name("John")
	 expert.expertises << Topic.find_by_title("rails")

	 expert = User.find_by_first_name("John")
	 expert.expertises << Topic.find_by_title("java")

	 expert = User.find_by_first_name("John")
	 expert.expertises << Topic.find_by_title("html")

	 expert = User.find_by_first_name("John")
	 expert.expertises << Topic.find_by_title("ruby")

	 expert = User.find_by_first_name("John")
	 expert.expertises << Topic.find_by_title("javascript")

	 expert = User.find_by_first_name("John")
	 expert.expertises << Topic.find_by_title("jquery")

	 expert = User.find_by_first_name("Stephen")
	 expert.expertises << Topic.find_by_title("full-stack")

	 expert = User.find_by_first_name("Stephen")
	 expert.expertises << Topic.find_by_title("web")

	 expert = User.find_by_first_name("Stephen")
	 expert.expertises << Topic.find_by_title("programming")

	 expert = User.find_by_first_name("Stephen")
	 expert.expertises << Topic.find_by_title("management")

	 expert = User.find_by_first_name("Stephen")
	 expert.expertises << Topic.find_by_title("presentation")

	 expert = User.find_by_first_name("Stephen")
	 expert.expertises << Topic.find_by_title("java")

	 expert = User.find_by_first_name("Stephen")
	 expert.expertises << Topic.find_by_title("html")

	 expert = User.find_by_first_name("Stephen")
	 expert.expertises << Topic.find_by_title("version control")

	 expert = User.find_by_first_name("Stephen")
	 expert.expertises << Topic.find_by_title("javascript")

	 expert = User.find_by_first_name("Stephen")
	 expert.expertises << Topic.find_by_title("jquery")

	 expert = User.find_by_first_name("Stephen")
	 expert.expertises << Topic.find_by_title("data visualization")

	 expert = User.find_by_first_name("Stephen")
	 expert.expertises << Topic.find_by_title("git")

	 expert = User.find_by_first_name("Chris")
	 expert.expertises << Topic.find_by_title("management")

	 expert = User.find_by_first_name("Chris")
	 expert.expertises << Topic.find_by_title("communication")

	 expert = User.find_by_first_name("Chris")
	 expert.expertises << Topic.find_by_title("sales")

	 expert = User.find_by_first_name("Chris")
	 expert.expertises << Topic.find_by_title("presentation")

	 expert = User.find_by_first_name("Chris")
	 expert.expertises << Topic.find_by_title("statistics")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("full-stack")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("web")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("programming")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("iOS")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("rails")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("java")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("html")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("ruby")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("javascript")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("jquery")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("algorithms")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("python")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("fortran")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("java")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("php")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("android")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("c")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("c++")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("objective c")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("git")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("subversion")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("version control")

	 expert = User.find_by_first_name("Mike")
	 expert.expertises << Topic.find_by_title("mobile")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("full-stack")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("web")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("programming")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("iOS")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("rails")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("java")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("html")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("ruby")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("javascript")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("jquery")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("algorithms")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("python")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("fortran")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("java")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("php")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("android")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("c")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("c++")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("objective c")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("git")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("subversion")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("version control")

	 expert = User.find_by_first_name("Marc")
	 expert.expertises << Topic.find_by_title("mobile")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("presentation")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("graphic design")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("data visualization")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("management")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("communication")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("sales")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("presentation")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("statistics")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("full-stack")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("web")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("programming")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("iOS")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("rails")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("java")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("html")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("ruby")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("javascript")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("jquery")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("algorithms")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("python")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("fortran")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("java")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("php")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("android")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("c")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("c++")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("objective c")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("git")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("subversion")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("version control")

	 expert = User.find_by_first_name("Oren")
	 expert.expertises << Topic.find_by_title("mobile")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("presentation")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("graphic design")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("data visualization")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("management")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("communication")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("sales")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("presentation")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("statistics")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("full-stack")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("web")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("programming")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("iOS")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("rails")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("java")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("html")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("ruby")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("javascript")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("jquery")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("algorithms")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("python")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("fortran")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("java")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("php")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("android")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("c")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("c++")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("objective c")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("git")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("subversion")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("version control")

	 expert = User.find_by_first_name("Jay")
	 expert.expertises << Topic.find_by_title("mobile")
  end
end

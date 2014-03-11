class PopulateUserHierarchy < ActiveRecord::Migration
  def change
	user = User.find_by_first_name("chris")
	 user.superiors << User.find_by_first_name("jay")

	user = User.find_by_first_name("oren")
	 user.superiors << User.find_by_first_name("jay")

	user = User.find_by_first_name("marc")
	 user.superiors << User.find_by_first_name("oren")

	user = User.find_by_first_name("oren")
	 user.subordinates << User.find_by_first_name("mike")

	user = User.find_by_first_name("jay")
	 user.subordinates << User.find_by_first_name("william")

	user = User.find_by_first_name("jay")
	 user.subordinates << User.find_by_first_name("veni")

	user = User.find_by_first_name("jay")
	 user.subordinates << User.find_by_first_name("john")

	user = User.find_by_first_name("jay")
	 user.subordinates << User.find_by_first_name("brett")

	user = User.find_by_first_name("jay")
	 user.subordinates << User.find_by_first_name("stephen")
  end
end

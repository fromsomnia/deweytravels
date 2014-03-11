class PopulateUserHierarchy < ActiveRecord::Migration
  def change
	user = User.find_by_first_name("Chris")
	 user.superiors << User.find_by_first_name("Jay")

	user = User.find_by_first_name("Oren")
	 user.superiors << User.find_by_first_name("Jay")

	user = User.find_by_first_name("Marc")
	 user.superiors << User.find_by_first_name("Oren")

	user = User.find_by_first_name("Oren")
	 user.subordinates << User.find_by_first_name("Mike")

	user = User.find_by_first_name("Jay")
	 user.subordinates << User.find_by_first_name("William")

	user = User.find_by_first_name("Jay")
	 user.subordinates << User.find_by_first_name("Veni")

	user = User.find_by_first_name("Jay")
	 user.subordinates << User.find_by_first_name("John")

	user = User.find_by_first_name("Jay")
	 user.subordinates << User.find_by_first_name("Brett")

	user = User.find_by_first_name("Jay")
	 user.subordinates << User.find_by_first_name("Stephen")
  end
end

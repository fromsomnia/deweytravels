var DeweyApp = angular.module('DeweyApp', ['ngRoute']);

DeweyApp.config(function ($routeProvider) {
  $routeProvider
    .when('/', {
    	controller: 'DeweyController',
    	templateUrl: '/login'
    })
    .when('/search', {
    	controller: 'DeweyController',
    	templateUrl: '/search'
    })
    .when('/user', {
    	controller: 'DeweyController',
    	templateUrl: '/user'
    })
    .when('/topic', {
    	controller: 'DeweyController',
    	templateUrl: '/topic'
    })
    .otherwise({ 
    	redirectTo: '/'
    });
});

DeweyApp.factory('DeweyFactory', function () {

	var factory, results, user, users, topic, topics;
  
  factory = {};
	results = [{name:"Veni Johanna",description:"Engineer"},{name:"Brett Solow",description:"Engineer"},{name:"Stephen Quinonez",description:"Engineer"},{name:"William Chidyausiku",description:"Engineer"},{name:"John Pulvera",description:"Engineer"},{name:"#full-stack",description:"4 people with this skill"}];
	user = {name: "Veni Johanna",description: "Engineer",email: "veni@stanford.edu",phone: "123-456-7890"};
	users = [{name:"Veni Johanna",description:"Engineer"},{name:"Brett Solow",description:"Engineer"},{name:"William Chidyausiku",description:"Engineer"},{name:"John Pulvera",description:"Engineer"}];
	topic = {name: "#full-stack",description: "4 people know this topic"};
	topics = [{name:"full-stack"},{name:"web"},{name:"programming"},{name:"iOS"},{name:"user growth"},{name:"algorithms"}];

	factory.getResults = function () {
		return results;
	};

	factory.getUser = function () {
		return user;
	};

	factory.getUsers = function () {
		return users;
	};

	factory.getTopic = function () {
		return topic;
	};

	factory.getTopics = function () {
		return topics;
	};

  return factory;
});

DeweyApp.controller('DeweyController', function ($scope, DeweyFactory) {

	function init () {
		$scope.results = DeweyFactory.getResults();
		$scope.user = DeweyFactory.getUser();
		$scope.users = DeweyFactory.getUsers();
		$scope.topic = DeweyFactory.getTopic();
		$scope.topics = DeweyFactory.getTopics();
	}

	(function () {
		init();
	})();

});


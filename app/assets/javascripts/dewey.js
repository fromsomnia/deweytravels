// constructor for DeweyApp
function Dewey () {

	var DeweyApp = angular.module('DeweyApp', ['ngRoute', 'ui.bootstrap']);

	DeweyApp
	.config(['$routeProvider', function ($routeProvider) {
	  $routeProvider
	    .when('/', {
	    	controller: 'DeweyController',
	    	templateUrl: '/login'
	    })
	    .when('/search', {
	    	redirectTo: '/search/_'
	    })
	    .when('/search/:query', {
	    	controller: 'DeweyController',
	    	templateUrl: '/search',
	    	resolve: {
	    		getResults: function (DeweyFactory) {
	    			return DeweyFactory.getResults();
	    		}
	    	}
	    })
	    .when('/users/:userId', {
	    	controller: 'DeweyController',
	    	templateUrl: '/user',
	    	resolve: {
	    		getUser: function (DeweyFactory) {
	    			return DeweyFactory.getUser();
	    		},
	    		getTopics: function (DeweyFactory) {
	    			return DeweyFactory.getTopics();
	    		},
	    		getLinks: function (DeweyFactory) {
	    			return DeweyFactory.getLinks();
	    		},
          getAllTopics: function(DeweyFactory) {
            return DeweyFactory.getAllTopics();
          }

	    	}
	    })
	    .when('/topics/:topicId', {
	    	controller: 'DeweyController',
	    	templateUrl: '/topic',
	    	resolve: {
	    		getTopic: function (DeweyFactory) {
	    			return DeweyFactory.getTopic();
	    		},

	    		getAllUsers: function (DeweyFactory) {
	    			return DeweyFactory.getAllUsers();
	    		},
	    		getUsers: function (DeweyFactory) {
	    			return DeweyFactory.getUsers();
	    		},
	    		getLinks: function (DeweyFactory) {
	    			return DeweyFactory.getLinks();
	    		}
	    	}
	    })
	    .otherwise({ 
	    	redirectTo: '/'
	    });
	}])
	.factory('DeweyFactory', ['$http', '$q', '$route', function ($http, $q, $route) {

		var factory = {};

		function getResults () {
			var defer = $q.defer(),
				params = $route.current.params;
			$http.get('/graphs/search.json?query=' + params.query).success(function (response) {

				// prep data (fix later)
				response = _.map(response, function (obj) {
					var val = obj['title'];
					if (val) {
						obj['first_name'] = val;
						obj['category'] = 'topics';								
					} else {
						obj['category'] = 'users';
					}
					if (!obj['image'])
						obj['image'] = 'picture_placeholder.png';
					if (!obj['department'])
						obj['department'] = 'topic';
					return obj;
				});

				factory.results = response;
				defer.resolve();
			});
			return defer.promise;
		}

		function getUser () {
			var defer = $q.defer(),
				params = $route.current.params;
			$http.get("/users/" + params.userId + ".json").success(function (response) {
				factory.user = response;
				defer.resolve();
			});
			return defer.promise;
		}

		function getUsers () {
			var defer = $q.defer(),
				params = $route.current.params;
			$http.get('/topics/' + params.topicId + '/users.json').success(function (response) {

				// prep data (fix later)
				response = _.map(response, function (obj) {
					if (obj['title']) {
						obj['category'] = 'topics';								
					} else {
						obj['category'] = 'users';
					}
					// console.log(obj);
					return obj;
				});

				factory.results = response;
				defer.resolve();
			});
			return defer.promise;
		}

		function getTopic () {
			var defer = $q.defer(),
				params = $route.current.params;
			$http.get('/topics/' + params.topicId + '.json').success(function (response) {
				factory.topic = response;
				defer.resolve();
			});
			return defer.promise;
		}

    function getAllTopics() {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/topics.json').success(function (response) {
        factory.all_topics = response;
        defer.resolve();
      });
      return defer.promise;
    }

    function getAllUsers() {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/users.json').success(function (response) {
        factory.all_users = response;
        defer.resolve();
      });
      return defer.promise;
    }

		function getTopics () {
			var defer = $q.defer(),
				params = $route.current.params;
			$http.get('/users/' + params.userId + '/topics.json').success(function (response) {
				factory.topics = response;
				defer.resolve();
			});
			return defer.promise;
		}

		function getLinks () {
			var defer = $q.defer(),
				params = $route.current.params;
				source = '';
				id = 0;
				if(params.topicId){
					source = '/topics/';
					id = params.topicId;
				}else{
					source = '/users/';
					id = params.userId;
				}
			$http.get(source + '' + id + '/most_connected.json').success(function (response) {
				factory.nodes_links = response;
				// console.log("source: " + source);
				// console.log(factory.nodes_links);
				defer.resolve();
			});
			return defer.promise;
		}
    factory.getAllTopics = getAllTopics
    factory.getAllUsers = getAllUsers
		factory.getResults = getResults;
		factory.getUser = getUser;
		factory.getUsers = getUsers;
		factory.getTopic = getTopic;
		factory.getTopics = getTopics;
		factory.getLinks = getLinks;
	  return factory;
  }])

	.controller('DeweyTopicController', ['$scope', '$location', 'DeweyFactory', function ($scope, $location, DeweyFactory) {
    $scope.user_choices = DeweyFactory.all_users;
    $scope.should_show_add_user_to_topic = true;
    
    $scope.addUserToTopic = function($item) {
      $.post('/topics/' + $scope.topic.id + '/add_user', {
        user_id: $item.id,
        id: $scope.topic.id
      }).done(function(response) {
        $scope.results.push($item);
        $(typeahead).val('');
        $scope.$apply();
      }).fail(function(response) {
        alert("Fail to add user to topic - please retry.");
      });
    };
  }])

	.controller('DeweyController', ['$scope', '$location', 'DeweyFactory', function ($scope, $location, DeweyFactory) {

		function init () {
			$scope.results = DeweyFactory.results;
			$scope.user = DeweyFactory.user;
			$scope.topic = DeweyFactory.topic;
			$scope.topics = DeweyFactory.topics;
      $scope.topic_choices =  DeweyFactory.all_topics;
			$scope.nodes_links = DeweyFactory.nodes_links;
			$scope.loginData = {};
			$scope.queryData = {};
		}

	  $scope.login = function () {
	  	$.post('/session/post_login', { 
	  		email: $scope.loginData.email, 
	  		password: $scope.loginData.password,
	  	}).done(function (response) {
	      $scope.$apply(function () {
	  	    $location.path('/search');
	      });
	    }).fail(function (response) {
	      alert("Invalid Socialcast email and password - please retry.");
	    });
	  };

		$scope.search = function () {
			if (event.keyCode == 13) {
				$location.path('/search/' + $scope.queryData.query);
			}
		};
    $scope.addTopicToUser = function($item) {
      $.post('/users/' + $scope.user.id + '/add_topic', {
        topic_id: $item.id,
        id: $scope.user.id
      }).done(function(response) {
        $scope.topics.push($item);
        $(typeahead).val('');
        $scope.$apply();
      }).fail(function(response) {
        alert("Fail to add topic to user - please retry.");
      });

    };

		(function () {
			init();
		})();

	}]);

	return DeweyApp;

};

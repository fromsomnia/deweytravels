// constructor for DeweyApp
function Dewey () {

	var DeweyApp = angular.module('DeweyApp', ['ngRoute', 'ui.bootstrap']);

  var BaseController = function ($scope, $location, DeweyFactory) {
	  $scope.results = DeweyFactory.results;
	  $scope.user = DeweyFactory.user;
	  $scope.topic = DeweyFactory.topic;
	  $scope.topics = DeweyFactory.topics;
    $scope.topic_choices =  DeweyFactory.all_topics;
	  $scope.nodes_links = DeweyFactory.nodes_links;
	  $scope.loginData = {};
	  $scope.queryData = {};

		$scope.search = function () {
			if (event.keyCode == 13) {
				$location.path('/search/' + $scope.queryData.query);
			}
		};
  };

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
	    		getResults: ['DeweyFactory', function (DeweyFactory) {
	    			return DeweyFactory.getResults();
	    		}]
	    	}
	    })
	    .when('/users/:userId', {
	    	controller: 'UserController',
	    	templateUrl: '/user',
	    	resolve: {
	    		getUser: ['DeweyFactory', function (DeweyFactory) {
	    			return DeweyFactory.getUser();
	    		}],
	    		getTopics: ['DeweyFactory', function (DeweyFactory) {
	    			return DeweyFactory.getTopics();
	    		}],
	    		getLinks: ['DeweyFactory', function (DeweyFactory) {
	    			return DeweyFactory.getLinks();
	    		}],
          getAllTopics: ['DeweyFactory', function(DeweyFactory) {
            return DeweyFactory.getAllTopics();
          }]

	    	}
	    })
	    .when('/topics/:topicId', {
	    	controller: 'TopicController',
	    	templateUrl: '/topic',
	    	resolve: {
	    		getTopic: ['DeweyFactory', function (DeweyFactory) {
	    			return DeweyFactory.getTopic();
	    		}],
	    		getAllUsers: ['DeweyFactory', function (DeweyFactory) {
	    			return DeweyFactory.getAllUsers();
	    		}],
	    		getUsers: ['DeweyFactory', function (DeweyFactory) {
	    			return DeweyFactory.getUsers();
	    		}],
	    		getLinks: ['DeweyFactory', function (DeweyFactory) {
	    			return DeweyFactory.getLinks();
	    		}]
	    	}
	    })
	    .otherwise({ 
	    	redirectTo: '/'
	    });
	}]);
	
	DeweyApp.factory('DeweyFactory', ['$http', '$q', '$route', function ($http, $q, $route) {

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
  .controller('DeweyController', ['$scope', '$injector', '$location', 'DeweyFactory', function($scope, $injector, $location, DeweyFactory) {
    $injector.invoke(BaseController, this, {$scope: $scope, $location: $location, DeweyFactory: DeweyFactory});
  }])
  .controller('LoginController', ['$scope', '$injector', '$location', 'DeweyFactory', function($scope, $injector, $location, DeweyFactory) {
    $scope.loginData = {};
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
  }])
  .controller('UserController', ['$scope', '$injector', '$location', 'DeweyFactory', function($scope, $injector, $location, DeweyFactory) {
    $injector.invoke(BaseController, this, {$scope: $scope, $location: $location, DeweyFactory: DeweyFactory});

    $scope.topic_choices =  DeweyFactory.all_topics;

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
  }])
	.controller('TopicController', ['$scope', '$injector', '$location', 'DeweyFactory', function ($scope, $injector, $location, DeweyFactory) {
    $injector.invoke(BaseController, this, {$scope: $scope, $location: $location, DeweyFactory: DeweyFactory});

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
  }]);

	return DeweyApp;

};

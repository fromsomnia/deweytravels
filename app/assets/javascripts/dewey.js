// constructor for DeweyApp
function Dewey () {

	// initialize DeweyApp
	var DeweyApp = angular.module('DeweyApp', ['ngRoute', 'ui.bootstrap']);

	// ...
	var BaseController = ['$scope', '$location', 'DeweyFactory', function ($scope, $location, DeweyFactory) {

		// bind data to the $scope
		$scope.results = DeweyFactory.results;
		$scope.user = DeweyFactory.user;
		$scope.topic = DeweyFactory.topic;
		$scope.topics = DeweyFactory.topics;
		$scope.topic_choices =  DeweyFactory.all_topics;
		$scope.nodes_links = DeweyFactory.nodes_links;
		$scope.loginData = {};
		$scope.queryData = {};

		// search using API
		$scope.search = function () {
			if (event.keyCode == 13) {
				$location.path('/search/' + $scope.queryData.query);
			}
		};
	}];

	// configuration
	DeweyApp.config(['$routeProvider', function ($routeProvider) {

	  // establish routes and resolve promises before displaying view
	  $routeProvider
	  	// default view
	    .when('/', {
	    	controller: 'LoginController',
	    	templateUrl: '/login'
	    })
	    // default search view
	    .when('/search', {
	    	redirectTo: '/search/_',
	    	controller: 'DeweyController',
	    })
	    // search view with a query
	    .when('/search/:query', {
	    	controller: 'DeweyController',
	    	templateUrl: '/search',
	    	resolve: {
	    		getResults: ['DeweyFactory', function (DeweyFactory) {
	    			return DeweyFactory.getResults();
	    		}]
	    	}
	    })
	    // user view
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
		        getAllTopics: ['DeweyFactory', function (DeweyFactory) {
		            return DeweyFactory.getAllTopics();
		        }]
	    	}
	    })
	    // topic view
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
	    // redirect if any other route
	    .otherwise({ 
	    	redirectTo: '/'
	    });

	}]);
	
	// factory as our model
	DeweyApp.factory('DeweyFactory', ['$http', '$q', '$route', function ($http, $q, $route) {

		// get search results from API
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

		// get user from API
		function getUser () {
			var defer = $q.defer(),
				params = $route.current.params;
			$http.get("/users/" + params.userId + ".json").success(function (response) {
				factory.user = response;
				defer.resolve();
			});
			return defer.promise;
		}

		// get topic's users from API
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
					return obj;
				});

				factory.results = response;
				defer.resolve();
			});
			return defer.promise;
		}

		// get topic from API
		function getTopic () {
			var defer = $q.defer(),
				params = $route.current.params;
			$http.get('/topics/' + params.topicId + '.json').success(function (response) {
				factory.topic = response;
				defer.resolve();
			});
			return defer.promise;
		}

		// get all topics from API
    function getAllTopics() {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/topics.json').success(function (response) {
        factory.all_topics = response;
        defer.resolve();
      });
      return defer.promise;
    }

    // get all users from API
    function getAllUsers() {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/users.json').success(function (response) {
        factory.all_users = response;
        defer.resolve();
      });
      return defer.promise;
    }

    // get user's topics from API
		function getTopics () {
			var defer = $q.defer(),
				params = $route.current.params;
			$http.get('/users/' + params.userId + '/topics.json').success(function (response) {
				factory.topics = response;
				defer.resolve();
			});
			return defer.promise;
		}

		// ...
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
				defer.resolve();
			});
			return defer.promise;
		}

		// return public factory methods
		var factory = {};
	    factory.getAllTopics = getAllTopics;
	    factory.getAllUsers = getAllUsers;
		factory.getResults = getResults;
		factory.getUser = getUser;
		factory.getUsers = getUsers;
		factory.getTopic = getTopic;
		factory.getTopics = getTopics;
		factory.getLinks = getLinks;
	  return factory;
  }]);

	// service that can be called from any controller to re-render the graph based on the new URL
	DeweyApp.factory("GraphService", function ($rootScope) {
		var factory = {};
		
		factory.renderGraph = function() {
			$rootScope.$broadcast("navigation");
		};

		return factory;
	});

	// ...
  DeweyApp.controller('DeweyController', ['$scope', '$injector', '$location', 'DeweyFactory', function ($scope, $injector, $location, DeweyFactory) {
    $injector.invoke(BaseController, this, {$scope: $scope, $location: $location, DeweyFactory: DeweyFactory});
  }]);

  // ...
  DeweyApp.controller('LoginController', ['$scope', '$injector', '$location', 'DeweyFactory', 'GraphService', function ($scope, $injector, $location, DeweyFactory, GraphService) {
    $scope.loginData = {};
	  $scope.login = function () {
	  	$.post('/session/post_login', { 
	  		email: $scope.loginData.email, 
	  		password: $scope.loginData.password,
	  	}).done(function (response) {
	      $scope.$apply(function () {
	  	    $location.path('/search');
	  	    force.start();
	      });
	    }).fail(function (response) {
	      alert("Invalid Socialcast email and password - please retry.");
	    });
	  };
	  GraphService.renderGraph();
  }]);

  // ...
  DeweyApp.controller('UserController', ['$scope', '$injector', '$location', 'DeweyFactory', 'GraphService', function ($scope, $injector, $location, DeweyFactory, GraphService) {

    $injector.invoke(BaseController, this, {$scope: $scope, $location: $location, DeweyFactory: DeweyFactory});
    $scope.topic_choices =  DeweyFactory.all_topics;

    $scope.addTopicToUser = function($item) {
      $.post('/users/' + $scope.user.id + '/add_topic', {
        topic_id: $item.id,
        id: $scope.user.id
      }).done(function(response) {
        DeweyFactory.getTopics();
        $(typeahead).val('');
        setTimeout(function() {
          $scope.$apply(function() {
            $scope.topics = DeweyFactory.topics;

          });
        }, 2000);
      }).fail(function(response) {
        alert("Fail to add topic to user - please retry.");
      });
    };
    GraphService.renderGraph();
  }]);

  // ...
  DeweyApp.controller('TopicController', ['$scope', '$injector', '$location', 'DeweyFactory', 'GraphService', function ($scope, $injector, $location, DeweyFactory, GraphService) {
    $injector.invoke(BaseController, this, {$scope: $scope, $location: $location, DeweyFactory: DeweyFactory});

    $scope.user_choices = DeweyFactory.all_users;
    $scope.should_show_add_user_to_topic = true;

    $scope.addUserToTopic = function($item) {
      $.post('/topics/' + $scope.topic.id + '/add_user', {
        user_id: $item.id,
        id: $scope.topic.id
      }).done(function(response) {
        DeweyFactory.getUsers();
        $(typeahead).val('');
        setTimeout(function() {
          $scope.$apply(function() {
            $scope.results = DeweyFactory.results;
          });
        }, 2000);
      }).fail(function(response) {
        alert("Fail to add user to topic - please retry.");
      });
    };
    GraphService.renderGraph();
  }]);

	// SVG graph controller
	DeweyApp.controller('GraphController', ['$scope', '$location', function ($scope, $location) {
		$scope.width = 750;
        $scope.height = 600;

        $scope.$on("navigation", function() {
			var arr = $location.$$path.split('/');
			var topicID = arr[2];
			var type = arr[1];
			makeGraph(type, topicID);
		});

        // this is called anything the "navigation" event is broadcast
		var makeGraph = function(nodeType, nodeID) {
	        var force = d3.layout.force()
	          .charge(-1200)
	          .linkDistance(205)
	          .size([$scope.width, $scope.height]);

	        $.get('/' + nodeType + '/' + nodeID + '/most_connected.json').success(function (graph) {
	        	$scope.nodes = graph.nodes;
				$scope.links = graph.links;

				for (var i=0; i < $scope.links.length ; i++) {
				$scope.links[i].strokeWidth = Math.round(Math.sqrt($scope.links[i].value))
				}

				for (var i=0; i < $scope.nodes.length ; i++) {
					$scope.nodes[i].radius = 10;
					// user if first_name defined
					if($scope.nodes[i].first_name != undefined) {
						$scope.nodes[i].href = "#/users/" + $scope.nodes[i].id;
						$scope.nodes[i].color = "#FFFF66";
						$scope.nodes[i].name = $scope.nodes[i].first_name + " " + $scope.nodes[i].last_name
					}
					// topic if title defined
					if ($scope.nodes[i].title != undefined) {
						$scope.nodes[i].href = "#/topics/" + $scope.nodes[i].id;
						$scope.nodes[i].color = "#00CC66";
						$scope.nodes[i].radius *= 6;
						$scope.nodes[i].name = $scope.nodes[i].title;
					}
				}

				force
				  .nodes($scope.nodes)
				  .links($scope.links).theta(1)
				  .on("tick", function(){$scope.$apply()})
				  .start();

	    	});
	    }
	}]);

	// translates circle xlink's to render as href's
	DeweyApp.directive('ngXlinkHref', function () {
	  return {
	    priority: 99,
	    restrict: 'A',
	    link: function (scope, element, attr) {
	      var attrName = 'xlink:href';
	      attr.$observe('ngXlinkHref', function (value) {
	        if (!value)
	          return;
	        attr.$set(attrName, value);
	      });
	    }
	  };
	});

	// return DeweyApp as a result of function invocation
	return DeweyApp;

};

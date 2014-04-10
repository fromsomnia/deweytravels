// constructor for DeweyApp


function Dewey() {

  // initialize DeweyApp
  var DeweyApp = angular.module('DeweyApp', ['ngRoute', 'ui.bootstrap', 'LocalStorageModule']);

  // ...
  var BaseController = ['$scope', '$location', 'DeweyFactory', function ($scope, $location, DeweyFactory) {
    // bind data to the $scope
    $scope.results = DeweyFactory.results;
    $scope.user = DeweyFactory.user;
    $scope.topic = DeweyFactory.topic;
    $scope.topics = DeweyFactory.topics;
    $scope.topic_choices = DeweyFactory.all_topics;
    $scope.nodes = DeweyFactory.nodes;
    $scope.links = DeweyFactory.links;
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
        }],
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
        getNodesAndLinks: ['DeweyFactory', function (DeweyFactory) {
          return DeweyFactory.getNodesAndLinks();
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
        getNodesAndLinks: ['DeweyFactory', function (DeweyFactory) {
          return DeweyFactory.getNodesAndLinks();
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
    function getResults() {
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
          if (!obj['image']) obj['image'] = 'picture_placeholder.png';
          if (!obj['department']) obj['department'] = 'topic';
          return obj;
        });

        factory.results = response;
        defer.resolve();
      });
      return defer.promise;
    }

    // get user from API
    function getUser() {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get("/users/" + params.userId + ".json").success(function (response) {
        factory.user = response;
        defer.resolve();
      });
      return defer.promise;
    }

    // get topic's users from API
    function getUsers() {
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
    function getTopic() {
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
    function getTopics() {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/users/' + params.userId + '/topics.json').success(function (response) {
        factory.topics = response;
        defer.resolve();
      });
      return defer.promise;
    }

    // ...
    function getNodesAndLinks() {
      var defer = $q.defer(),
        params = $route.current.params;
      source = '';
      id = 0;
      if (params.topicId) {
        source = '/topics/';
        id = params.topicId;
      } else {
        source = '/users/';
        id = params.userId;
      }

      $http.get(source + '' + id + '/most_connected.json').success(function (response) {
        factory.nodes = response.nodes;
        factory.links = response.links;

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
    factory.getNodesAndLinks = getNodesAndLinks;
    return factory;

  }]);

  DeweyApp.factory('authInterceptor', function ($rootScope, $location, $q, localStorageService) {
    return {
      request: function (config) {
        config.headers = config.headers || {};
        var token = localStorageService.get('dewey_auth_token');
        if (token) {
          config.headers.Authorization = 'Token token=' + token;
        }
        return config;
      },
      responseError: function(rejection) {
        if (rejection.status === 401) {
          // handle the case where the user is not authenticated
          $location.path('/');
        }
        return $q.reject(rejection);
      }
    };
  });

  DeweyApp.config(function ($httpProvider) {
    $httpProvider.interceptors.push('authInterceptor');
  });
  // ...
  DeweyApp.controller('DeweyController', ['$scope', '$injector', '$location', 'DeweyFactory', function ($scope, $injector, $location, DeweyFactory) {
    $injector.invoke(BaseController, this, {
      $scope: $scope,
      $location: $location,
      DeweyFactory: DeweyFactory
    });
  }]);

  // ...
  DeweyApp.controller('LoginController', ['$scope', '$injector', '$location', 'localStorageService', 'DeweyFactory', function ($scope, $injector, $location, localStorageService, DeweyFactory) {
    $scope.loginData = {};
    
    var token = localStorageService.get('dewey_auth_token');
    if (token) {
      $location.path('/search');
    }

    // ...
    $scope.login = function () {
      $.post('/sessions/post_login.json', {
        email: $scope.loginData.email,
        password: $scope.loginData.password,
      }).done(function (response) {
        localStorageService.add('dewey_auth_token', response.auth_token);

        $scope.$apply(function () {
          $location.path('/search');
        });
      }).fail(function (response) {
        delete $window.sessionStorage.token;
        alert("Invalid Socialcast email and password - please retry.");
      });
    };
  }]);

  DeweyApp.controller('UserController', ['$http', '$scope', '$injector', '$location', 'DeweyFactory', function ($http, $scope, $injector, $location, DeweyFactory) {

    $injector.invoke(BaseController, this, {
      $scope: $scope,
      $location: $location,
      DeweyFactory: DeweyFactory
    });
    $scope.topic_choices = DeweyFactory.all_topics;

    $scope.updateTopics = function() {
      $injector.get('$rootScope').$broadcast('graphUpdated');
      DeweyFactory.getTopics();
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.topics = DeweyFactory.topics;
        });
      }, 500);
    };

    $scope.removeTopicFromUser = function($event, $tagID) {
      $http({
        url: '/users/' + $scope.user.id + '/remove_topic',
        method: "POST",
        data: { topic_id: $tagID,
                id: $scope.user.id}
      }).success(function(data, status, headers, config) {
        $scope.updateTopics();
      });
    };
    $scope.addTopicToUser = function ($item) {
      $http({
        url: '/users/' + $scope.user.id + '/add_topic',
        method: "POST",
        data: { topic_id: $item.id,
                id: $scope.user.id}
      }).success(function (response) {
        $scope.updateTopics();
      }).error(function (response) {
        alert("Fail to add topic to user - please retry.");
      });
    };
  }]);

  // ...
  DeweyApp.controller('TopicController', ['$http', '$scope', '$injector', '$location', 'DeweyFactory', function ($http, $scope, $injector, $location, DeweyFactory) {
    $injector.invoke(BaseController, this, {
      $scope: $scope,
      $location: $location,
      DeweyFactory: DeweyFactory
    });

    $scope.user_choices = DeweyFactory.all_users;
    $scope.should_show_add_user_to_topic = true;

    $scope.updateUsers = function() {
      $injector.get('$rootScope').$broadcast('graphUpdated');
      DeweyFactory.getUsers();
      $(typeahead).val('');
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.results = DeweyFactory.results;
        });
      }, 500);
    };

    $scope.removeUserFromTopic = function($event, $userID) {
      $http({
        url: '/topics/' + $scope.topic.id + '/remove_user',
        method: "POST",
        data: { user_id: $userID,
                id: $scope.topic.id }
      }).success(function (response) {
        $scope.updateUsers();
      });
    };

    $scope.addUserToTopic = function ($item) {
      $http({
        url: '/topics/' + $scope.topic.id + '/add_user',
        method: "POST",
        data: { user_id: $item.id,
                id: $scope.topic.id }
      }).success(function (response) {
        $scope.updateUsers();
      }).error(function (response) {
        alert("Fail to add user to topic - please retry.");
      });
    };
  }]);

  // SVG graph controller

  DeweyApp.controller('GraphController', ['$http', '$scope', '$injector', '$location', 'DeweyFactory', function ($http, $scope, $injector, $location, DeweyFactory) {
    $injector.invoke(BaseController, this, {
      $scope: $scope,
      $location: $location,
      DeweyFactory: DeweyFactory
    });

    $scope.$on('graphUpdated', function() {
      DeweyFactory.getNodesAndLinks();
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.nodes = DeweyFactory.nodes;
          $scope.links = DeweyFactory.links;
          $scope.makeGraph();
        });
      }, 500);
    });

    $scope.width = 750;
    $scope.height = 600;

    $scope.upvote = function(link) {
      $http({
        url: '/connections/' + link.connection.id + '/upvote',
        method: "POST",
        data: { id: link.connection.id,
                connection_type: link.connectionType }
      }).success(function(data, status, headers, config) {
        link.is_upvoted = true;
        link.is_downvoted = false;
      });
    };

    $scope.downvote = function(link) {
      $http({
        url: '/connections/' + link.connection.id + '/downvote',
        method: "POST",
        data: { id: link.connection.id,
                connection_type: link.connectionType }
      }).success(function(data, status, headers, config) {
        link.is_upvoted = false;
        link.is_downvoted = true;
      });
    }

    $scope.makeGraph = function() {
      var force = d3.layout.force().charge(-1200).linkDistance(205).size([$scope.width, $scope.height]);
  
      for (var i = 0; i < $scope.links.length; i++) {

        $scope.links[i].strokeWidth = 2;
        // TODO: uncomment this when the line has strength value.
        // $scope.links[i].strokeWidth = Math.round(Math.sqrt($scope.links[i].value))
      }
  
      for (var i = 0; i < $scope.nodes.length; i++) {
        $scope.nodes[i].radius = 10;
        // user if first_name defined
        if ($scope.nodes[i].first_name != undefined) {
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
  
      force.nodes($scope.nodes).links($scope.links).theta(1).on("tick", function () {
        $scope.$apply()
      }).start();
    }

    $scope.makeGraph();
  }]);

  // translates circle xlink's to render as href's
  DeweyApp.directive('ngXlinkHref', function () {
    return {
      priority: 99,
      restrict: 'A',
      link: function (scope, element, attr) {
        var attrName = 'xlink:href';
        attr.$observe('ngXlinkHref', function (value) {
          if (!value) return;
          attr.$set(attrName, value);
        });
      }
    };
  });

  // return DeweyApp as a result of function invocation
  return DeweyApp;

};

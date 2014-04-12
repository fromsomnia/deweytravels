// constructor for DeweyApp
function Dewey () {

  // ngRoute is for routing; ui.bootstrap is for Angular UI Bootstrap components
  var DeweyApp = angular.module('DeweyApp', ['ngRoute', 'ui.bootstrap']);

  DeweyApp.config(['$routeProvider', function ($routeProvider) {

    // establish routes and resolve promises before displaying view
    $routeProvider
      .when('/', {
        controller: 'LoginController',
        templateUrl: '/login'
      })
      .when('/search', {
        redirectTo: '/search/_',
      })
      .when('/search/:query', {
        controller: 'SearchController',
        templateUrl: '/search',
        resolve: {
          getSearchResults: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getSearchResults();
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
            return DeweyFactory.getTopicsForUser();
          }],
          getAllTopics: ['DeweyFactory', function (DeweyFactory) {
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
            return DeweyFactory.getUsersForTopic();
          }],
        }
      })
      .otherwise({
        redirectTo: '/'
      });

  }]);

  // factory as our model; calls the API for data
  DeweyApp.factory('DeweyFactory', ['$http', '$q', '$route', function ($http, $q, $route) {

    function prepareSearchResultData (results) {
      return _.map(results, function (result) {
        if (result.first_name && result.last_name) {
          result.category = 'users';
          result.name = result.first_name + ' ' + result.last_name;
          result.description = result.department || 'employee';
        } else {
          result.category = 'topics';
          result.name = result.title;
          result.description = 'topic';
        }
        if (!result.image)
          result.image = 'picture_placeholder.png';
        return result;
      });
    }

    function prepareUsersData (users) {
      return _.map(users, function (user) {
        user.name = user.first_name + ' ' + user.last_name;
        user.description = user.department || 'employee';
        user.category = 'users';
        return user;
      });
    }

    function getSearchResults () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/graphs/search.json?query=' + params.query).success(function (response) {
        factory.searchResults = prepareSearchResultData(response);
        defer.resolve();
      });
      return defer.promise;
    }

    function getUser () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/users/' + params.userId + '.json').success(function (response) {
        factory.user = response;
        defer.resolve();
      });
      return defer.promise;
    }

    function getUsersForTopic () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/topics/' + params.topicId + '/users.json').success(function (response) {
        factory.usersForTopic = prepareUsersData(response);
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

    function getAllTopics () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/topics.json').success(function (response) {
        factory.allTopics = response;
        defer.resolve();
      });
      return defer.promise;
    }

    function getAllUsers () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/users.json').success(function (response) {
        factory.allUsers = response;
        defer.resolve();
      });
      return defer.promise;
    }

    function getTopicsForUser () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/users/' + params.userId + '/topics.json').success(function (response) {
        factory.topicsForUser = response;
        defer.resolve();
      });
      return defer.promise;
    }

    function getNodesAndLinks (type, id, callback) {
      $http.get('/' + type + '/' + id + '/most_connected.json')
        .success(function (response) {
          factory.nodesAndLinks = response;
          callback();
        });
    }

    // return public factory methods
    var factory = {};
    factory.getAllTopics = getAllTopics;
    factory.getAllUsers = getAllUsers;
    factory.getSearchResults = getSearchResults;
    factory.getUser = getUser;
    factory.getUsersForTopic = getUsersForTopic;
    factory.getTopic = getTopic;
    factory.getTopicsForUser = getTopicsForUser;
    factory.getNodesAndLinks = getNodesAndLinks;
    return factory;

  }]);

  // controller for all views; other controllers inherit from this
  DeweyApp.controller('BaseController', ['$scope', '$location', '$http', 'DeweyFactory', function ($scope, $location, $http, DeweyFactory) {

    $scope.queryData = {};
    $scope.deweyGraph = $scope.deweyGraph || DeweyGraph('#dewey-graph', null);

    $scope.$watch('graphParams', function (newValue, oldValue) {
      if (!newValue){
        return;
      }
      $scope.renderGraph(newValue.type, newValue.id);
    });

    $scope.renderGraph = function (type, id) {
      DeweyFactory.getNodesAndLinks(type, id, function () {
        $scope.deweyGraph.render(DeweyFactory.nodesAndLinks);
      });
    };

    $scope.search = function () {
      if (event.keyCode == 13) {
        $location.path('/search/' + $scope.queryData.query);
      }
    };

  }]);

  DeweyApp.controller('SearchController', ['$controller', '$scope', '$location', 'DeweyFactory', function ($controller, $scope, $location, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.searchResults = DeweyFactory.searchResults;

  }]);

  DeweyApp.controller('LoginController', ['$scope', '$location', function ($scope, $location) {

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
        alert('Invalid Socialcast email and password - please retry.');
      });
    };

  }]);

  DeweyApp.controller('UserController', ['$scope', '$controller', '$location', 'DeweyFactory', function ($scope, $controller, $location, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.user = DeweyFactory.user;
    $scope.topicsForUser = DeweyFactory.topicsForUser;
    $scope.topicChoices = DeweyFactory.allTopics;
    $scope.graphParams = {
      type: 'users',
      id: $scope.user.id
    };

    $scope.updateTopics = function () {
      DeweyFactory.getTopicsForUser();
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.topicsForUser = DeweyFactory.topicsForUser;
        });
      }, 500);
      // bug with updating graph
      $scope.renderGraph($scope.graphParams.type, $scope.graphParams.id);
    };

    $scope.removeTopicFromUser = function ($event, $tagID) {
      $.post('/users/' + $scope.user.id + '/remove_topic', {
        topic_id: $tagID,
        id: $scope.user.id
      }).done(function (response) {
        $scope.updateTopics();
      });
    };

    $scope.addTopicToUser = function ($item) {
      $.post('/users/' + $scope.user.id + '/add_topic', {
        topic_id: $item.id,
        id: $scope.user.id
      }).done(function (response) {
        $scope.updateTopics();
      }).fail(function (response) {
        alert('Fail to add topic to user - please retry.');
      });
    };

  }]);

  DeweyApp.controller('TopicController', ['$scope', '$controller', '$location', 'DeweyFactory', function ($scope, $controller, $location, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.usersForTopic = DeweyFactory.usersForTopic;
    $scope.topic = DeweyFactory.topic;
    $scope.userChoices = DeweyFactory.allUsers;
    $scope.shouldShowAddUserToTopic = true;
    $scope.graphParams = {
      type: 'topics',
      id: $scope.topic.id
    };

    $scope.updateUsers = function () {
      DeweyFactory.getUsersForTopic();
      $(typeahead).val('');
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.usersForTopic = DeweyFactory.usersForTopic;
        });
      }, 500);
      $scope.renderGraph($scope.graphParams.type, $scope.graphParams.id);
    };

    $scope.removeUserFromTopic = function ($event, $userID) {
      $.post('/topics/' + $scope.topic.id + '/remove_user', {
        user_id: $userID,
        id: $scope.topic.id
      }).done(function (response) {
        $scope.updateUsers();
      });
    };

    $scope.addUserToTopic = function ($item) {
      $.post('/topics/' + $scope.topic.id + '/add_user', {
        user_id: $item.id,
        id: $scope.topic.id
      }).done(function (response) {
        $scope.updateUsers();
      }).fail(function (response) {
        alert('Fail to add user to topic - please retry.');
      });
    };

  }]);

  return DeweyApp;

};

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

    // return public factory methods
    var factory = {};
    factory.getAllTopics = getAllTopics;
    factory.getAllUsers = getAllUsers;
    factory.getSearchResults = getSearchResults;
    factory.getUser = getUser;
    factory.getUsersForTopic = getUsersForTopic;
    factory.getTopic = getTopic;
    factory.getTopicsForUser = getTopicsForUser;
    return factory;

  }]);

  // controller for all views; other controllers inherit from this
  DeweyApp.controller('BaseController', ['$scope', '$location', '$http', 'DeweyFactory', function ($scope, $location, $http, DeweyFactory) {

    $scope.queryData = {};

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
    $scope.nodeType = 'users';
    $scope.nodeId = $scope.user.id;

    $scope.updateTopics = function () {
      DeweyFactory.getTopicsForUser();
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.topicsForUser = DeweyFactory.topicsForUser;
        });
      }, 500);
      // TODO: redraw graph
    };

    $scope.removeTopicFromUser = function ($event, $tagID) {
      $.post('/users/' + $scope.user.id + '/remove_topic', {
        topic_id: $tagID,
        id: $scope.user.id
      }).done(function (response) {
        $scope.updateTopics();
        // TODO: redraw graph
      });
    };

    $scope.addTopicToUser = function ($item) {
      $.post('/users/' + $scope.user.id + '/add_topic', {
        topic_id: $item.id,
        id: $scope.user.id
      }).done(function (response) {
        $scope.updateTopics();
        // TODO: redraw graph
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
    $scope.nodeType = 'topics';
    $scope.nodeId = $scope.topic.id;

    $scope.updateUsers = function () {
      DeweyFactory.getUsers();
      $(typeahead).val('');
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.usersForTopic = DeweyFactory.usersForTopic;
        });
      }, 500);
      // TODO: update graph
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
        // TODO: redraw graph
      }).fail(function (response) {
        alert('Fail to add user to topic - please retry.');
      });
    };

  }]);

  // directive for data visualization
  DeweyApp.directive('dwVisualization', function () {

    var directiveDefinitionObject = {
      restrict: 'E',
      scope: {
        url: '@'
      },
      link: function (scope, element, attrs) {

        // calculate width and height each time directive initiates
        var width = $(window).width(),
          height = $(window).height(),
          force = d3.layout
            .force()
            .charge(-1200)
            .linkDistance(205)
            .size([width, height]);

        // svg containers
        var svg = d3.select(element[0])
          .append('svg')
          .attr('width', '100%')
          .attr('height', '100%');
        var container = svg.append('g')
          .attr('class', 'graph-container');

        // watch if url value changes
        scope.$watch('url', function (newUrl, oldUrl) {

          if (!newUrl) {
            return;
          }

          // clear all previous elements
          container.selectAll('*').remove();

          // calls the API
          $.get(newUrl)
            .success(function (data) {

              // svg containers
              var links = container.append('g')
                .attr('class', 'links');
              var nodes = container.append('g')
                .attr('class', 'nodes');

              var linkContainer = links.selectAll('g')
                .data(data.links)
                .enter()
                .append('g');

              var line = linkContainer.append('line')
                .attr('class', 'link')
                .attr('stroke-width', function (datum) {
                  return 2;
                });

              var nodeContainer = nodes.selectAll('g')
                .data(data.nodes)
                .enter()
                .append('g');

              var anchor = nodeContainer.append('a')
                .attr('xlink:href', function (datum) {
                  if (datum.first_name) {
                    return '#/users/' + datum.id;
                  }
                  return '#/topics/' + datum.id;
                });

              var circle = anchor.append('circle')
                .attr('class', 'node')
                .attr('r', function (datum) {
                  if (datum.first_name) {
                    datum.r = 10;
                  } else {
                    datum.r = 60;
                  }
                  return datum.r;
                })
                .attr('fill', function (datum) {
                  if (datum.first_name) {
                    return '#FFFF66';
                  }
                  return '#00CC66';
                });

              var text = nodeContainer.append('text')
                .attr('pointer-events', 'none')
                .text(function (datum) {
                  if (datum.first_name) {
                    return datum.first_name + ' ' + datum.last_name;
                  }
                  return datum.title;
                });

              // tick function calculations position values for graph elements
              function tick () {
                nodeContainer.attr('transform', function (datum) {
                  datum.x = Math.max(datum.r, Math.min(width - datum.r, datum.x));
                  datum.y = Math.max(datum.r, Math.min(height - datum.r, datum.y));
                  return 'translate(' + datum.x + ',' + datum.y + ')';
                });
                text.attr('dx', function (datum) {
                    return '-' + $(this).width() / 2;
                  });
                line.attr('x1', function (datum) {
                    return datum.source.x;
                  })
                  .attr('y1', function (datum) {
                    return datum.source.y;
                  })
                  .attr('x2', function (datum) {
                    return datum.target.x;
                  })
                  .attr('y2', function (datum) {
                    return datum.target.y;
                  });
              }

              // apply force animations on graph
              force.nodes(data.nodes)
                .links(data.links)
                .theta(1)
                .on('tick', tick)
                .start();

            });
        });
      }
    };

    return directiveDefinitionObject;

  });

  return DeweyApp;

};

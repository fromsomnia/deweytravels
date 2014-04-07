// constructor for DeweyApp
function Dewey() {

  // initialize DeweyApp
  // ngRoute is for routing; ui.bootstrap is for Angular UI Bootstrap components
  var DeweyApp = angular.module('DeweyApp', ['ngRoute', 'ui.bootstrap']);

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
      })
      // search view with a query
      .when('/search/:query', {
        controller: 'SearchController',
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
      $http.get('/users/' + params.userId + '.json').success(function (response) {
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

    // get all links from a user or topic
    function getLinks() {
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
  // DeweyApp.factory('GraphService', ['$rootScope', function ($rootScope) {

  //   var factory = {};
  //   factory.renderGraph = function () {
  //     $rootScope.$broadcast('navigation');
  //   };
  //   return factory;

  // }]);

  // controller for all views; other controllers inherit from this
  // DeweyApp.controller('BaseController', ['$scope', '$location', 'DeweyFactory', 'GraphService', function ($scope, $location, DeweyFactory, GraphService) {
  DeweyApp.controller('BaseController', ['$scope', '$location', 'DeweyFactory', function ($scope, $location, DeweyFactory) {

    // bind data to the $scope
    $scope.results = DeweyFactory.results;
    $scope.user = DeweyFactory.user;
    $scope.topic = DeweyFactory.topic;
    $scope.topics = DeweyFactory.topics;
    $scope.nodes_links = DeweyFactory.nodes_links;
    $scope.loginData = {};
    $scope.queryData = {};

    $scope.initGraphVars = function () {
      // debugger;
      if ($scope.user) {
        $scope.nodeType = 'users';
        $scope.nodeId = $scope.user.id;      
      }
      else if ($scope.topic) {
        $scope.nodeType = 'topics';
        $scope.nodeId = $scope.topic.id;      
      }
    };

    // search using API
    $scope.search = function () {
      if (event.keyCode == 13) {
        $location.path('/search/' + $scope.queryData.query);
      }
    };

    // GraphService.renderGraph();
    // TODO: update scope's nodeType and nodeId

  }]);

  // controller for the Search view
  DeweyApp.controller('SearchController', ['$controller', '$scope', '$location', 'DeweyFactory', function ($controller, $scope, $location, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });

    // TODO: clear graph

  }]);

  // controller for the Login view
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

  // controller for the User view
  DeweyApp.controller('UserController', ['$scope', '$controller', '$location', 'DeweyFactory', function ($scope, $controller, $location, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });

    $scope.topic = undefined;
    $scope.initGraphVars();
    
    $scope.topic_choices = DeweyFactory.all_topics;

    $scope.updateTopics = function () {
      DeweyFactory.getTopics();
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.topics = DeweyFactory.topics;
        });
      }, 2000);

      // TODO: redraw graph

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

  // controller for the Topic view
  DeweyApp.controller('TopicController', ['$scope', '$controller', '$location', 'DeweyFactory', function ($scope, $controller, $location, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });


    // debugger;
    $scope.user = undefined;
    $scope.initGraphVars();

    $scope.user_choices = DeweyFactory.all_users;
    $scope.should_show_add_user_to_topic = true;

    $scope.updateUsers = function () {
      DeweyFactory.getUsers();
      $(typeahead).val('');
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.results = DeweyFactory.results;
        });
      }, 2000);

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
      }).fail(function (response) {
        alert('Fail to add user to topic - please retry.');
      });
    };

  }]);

  // DeweyApp.controller('GraphController', ['$scope', '$controller', function ($scope, $controller) {
  //   $controller('BaseController', {
  //     $scope: $scope
  //   });
  //   $scope.nodeType = 'users';
  //   $scope.nodeId = '5';
  // }]);

  // controller for the Graph view
  // DeweyApp.controller('GraphController', ['$scope', '$location', function ($scope, $location) {

  //   $scope.width = 750;
  //   $scope.height = 600;

  //   // triggered when 'navigation' event is broadcast
  //   $scope.$on('navigation', function () {
  //     var arr = $location.$$path.split('/');
  //     var topicID = arr[2];
  //     var type = arr[1];
  //     makeGraph(type, topicID);
  //   });

  //   // creates the D3 graph
  //   var makeGraph = function (nodeType, nodeID) {

  //     var force = d3.layout
  //       .force()
  //       .charge(-1200)
  //       .linkDistance(205)
  //       .size([$scope.width, $scope.height]);

  //     // calls the API
  //     $.get('/' + nodeType + '/' + nodeID + '/most_connected.json')
  //       .success(function (graph) {

  //         $scope.nodes = graph.nodes;
  //         $scope.links = graph.links;

  //         for (var i = 0; i < $scope.links.length; i++) {
  //           $scope.links[i].strokeWidth = Math.round(Math.sqrt($scope.links[i].value))
  //         }

  //         for (var i = 0; i < $scope.nodes.length; i++) {
  //           $scope.nodes[i].radius = 10;
  //           // user if first_name defined
  //           if ($scope.nodes[i].first_name != undefined) {
  //             $scope.nodes[i].href = '#/users/' + $scope.nodes[i].id;
  //             $scope.nodes[i].color = '#FFFF66';
  //             $scope.nodes[i].name = $scope.nodes[i].first_name + ' ' + $scope.nodes[i].last_name
  //           }
  //           // topic if title defined
  //           if ($scope.nodes[i].title != undefined) {
  //             $scope.nodes[i].href = '#/topics/' + $scope.nodes[i].id;
  //             $scope.nodes[i].color = '#00CC66';
  //             $scope.nodes[i].radius *= 6;
  //             $scope.nodes[i].name = $scope.nodes[i].title;
  //           }
  //         }

  //         force.nodes($scope.nodes).links($scope.links).theta(1).on('tick', function () {
  //           $scope.$apply()
  //         }).start();

  //       });

  //   };
    
  // }]);

  // directive for data visualization
  DeweyApp.directive('dwVisualization', function () {

    // var width = 750,
    //   height = 600,
    // var width = '100%',
    //   height = '100%',
    var width = $(window).width(),
      height = $(window).height(),
      force = d3.layout
        .force()
        .charge(-1200)
        .linkDistance(205)
        .size([width, height]);

    var directiveDefinitionObject = {
      restrict: 'E',
      scope: {
        url: '@' // '/:nodeType/:nodeID/most_connected.json'
      },
      link: function (scope, element, attrs) {

        var svg = d3.select(element[0])
          .append('svg')
          .attr('width', '100%')
          .attr('height', '100%');

        var container = svg.append('g');

        scope.$watch('url', function (newUrl, oldUrl) {

          container.selectAll('*').remove();

          if (!newUrl) {
            return;
          }

          // calls the API
          $.get(newUrl)
            .success(function (data) {

              var line = container.selectAll('line')
                .data(data.links)
                .enter()
                .append('line')
                .attr('class', 'link')
                .attr('stroke-width', function (datum) {
                  return 2;
                });

              var g = container.selectAll('g')
                .data(data.nodes)
                .enter()
                .append('g');

              var a = g.append('a')
                .attr('ngXlinkHref', function (datum) {
                  if (datum.first_name) {
                    return '#/users/' + datum.id;
                  }
                  return '#/topics/' + datum.id;
                });

              var circle = a.append('circle')
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

              var text = g.append('text')
                .attr('pointer-events', 'none')
                .text(function (datum) {
                  if (datum.first_name) {
                    return datum.first_name + ' ' + datum.last_name;
                  }
                  return datum.title;
                });

              function tick () {
                g.attr('transform', function (datum) {
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

  // translates circle xlink's to render as href's
  // DeweyApp.directive('ngXlinkHref', function () {

  //   return {
  //     priority: 99,
  //     restrict: 'A',
  //     link: function (scope, element, attr) {
  //       var attrName = 'xlink:href';
  //       attr.$observe('ngXlinkHref', function (value) {
  //         if (!value) return;
  //         attr.$set(attrName, value);
  //       });
  //     }
  //   };

  // });

  // return DeweyApp as a result of function invocation
  return DeweyApp;

};

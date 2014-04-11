// constructor for DeweyApp
function Dewey () {

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
          if (obj.first_name && obj.last_name) {
            obj.category = 'users';
            obj.name = obj.first_name + ' ' + obj.last_name;
            obj.description = (obj.department) ? obj.department : 'employee';
          } else {
            obj.category = 'topics';
            obj.name = obj.title;
            obj.description = 'topic';
          }
          // var val = obj['title'];
          // if (val) {
          //   obj['first_name'] = val;
          //   obj['category'] = 'topics';
          // } else {
          //   obj['category'] = 'users';
          // }          
          // if (!obj['image']) obj['image'] = 'picture_placeholder.png';
          // if (!obj['department']) obj['department'] = 'topic';
          if (!obj.image)
            obj.image = 'picture_placeholder.png';
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
      $http.get('/users/' + params.userId + '.json').success(function (response) {
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
    function getAllTopics () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/topics.json').success(function (response) {
        factory.allTopics = response;
        defer.resolve();
      });
      return defer.promise;
    }

    // get all users from API
    function getAllUsers () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/users.json').success(function (response) {
        factory.allUsers = response;
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

    // return public factory methods
    var factory = {};
    factory.getAllTopics = getAllTopics;
    factory.getAllUsers = getAllUsers;
    factory.getResults = getResults;
    factory.getUser = getUser;
    factory.getUsers = getUsers;
    factory.getTopic = getTopic;
    factory.getTopics = getTopics;
    return factory;

  }]);

  // controller for all views
  // other controllers inherit from this
  DeweyApp.controller('BaseController', ['$scope', '$location', '$http', 'DeweyFactory', function ($scope, $location, $http, DeweyFactory) {

    $scope.queryData = {};

    // TODO: autosuggest
    // function autoSuggest (query, callback) {
    //   $http.get('/graphs/search.json?query=' + query).success(function (response) {
    //     callback(response);
    //   });
    // }

    $scope.search = function () {
      if (event.keyCode == 13) {
        $location.path('/search/' + $scope.queryData.query);
      }
      // } else {
      //   var results = autoSuggest($scope.queryData.query, function (data) {
      //     console.log(JSON.toString(data));
      //   });
      // }
    };

  }]);

  // controller for the Search view
  DeweyApp.controller('SearchController', ['$controller', '$scope', '$location', 'DeweyFactory', function ($controller, $scope, $location, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.results = DeweyFactory.results;

  }]);

  // controller for the Login view
  DeweyApp.controller('LoginController', ['$scope', '$location', function ($scope, $location) {

    // does not inherit from BaseController...
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
    $scope.user = DeweyFactory.user;
    $scope.topics = DeweyFactory.topics;
    $scope.topicChoices = DeweyFactory.allTopics;
    $scope.nodeType = 'users';
    $scope.nodeId = $scope.user.id;

    $scope.updateTopics = function () {
      DeweyFactory.getTopics();
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.topics = DeweyFactory.topics;
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

  // controller for the Topic view
  DeweyApp.controller('TopicController', ['$scope', '$controller', '$location', 'DeweyFactory', function ($scope, $controller, $location, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.results = DeweyFactory.results;
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
          $scope.results = DeweyFactory.results;
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

    // directive object
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

              // TODO: voting UI
              // var voteContainer = linkContainer.append('foreignobject')
              //   .attr('width', 30)
              //   .attr('height', 30);

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

              // tick function calculations positional values for graph elements
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
                // TODO: update voteContainer position on tick
                // voteContainer.attr('x', function (datum) {
                //     return (datum.source.x + datum.target.x) / 2 - 50;
                //   })
                //   .attr('y', function (datum) {
                //     return (datum.source.y + datum.target.y) / 2 - 50;
                //   });
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

  // SVG graph controller
  // DeweyApp.controller('GraphController', ['$scope', '$injector', '$location', 'DeweyFactory', function ($scope, $injector, $location, DeweyFactory) {
    
  //   $injector.invoke(BaseController, this, {
  //     $scope: $scope,
  //     $location: $location,
  //     DeweyFactory: DeweyFactory
  //   });

  //   $scope.$on('graphUpdated', function() {
  //     DeweyFactory.getNodesAndLinks();
  //     setTimeout(function () {
  //       $scope.$apply(function () {
  //         $scope.nodes = DeweyFactory.nodes;
  //         $scope.links = DeweyFactory.links;
  //         $scope.makeGraph();
  //       });
  //     }, 500);
  //   });

  //   $scope.width = 750;
  //   $scope.height = 600;

  //   $scope.upvote = function(link) {
  //     $.post('/connections/' + link.connection.id + '/upvote', {
  //       id: link.connection.id,
  //       connection_type: link.connectionType
  //     }).done(function(response) {
  //       link.is_upvoted = true;
  //       link.is_downvoted = false;
  //       $scope.$apply();
  //     });
  //   };

  //   $scope.downvote = function(link) {
  //     $.post('/connections/' + link.connection.id + '/downvote', {
  //       id: link.connection.id,
  //       connection_type: link.connectionType
  //     }).done(function(response) {
  //       link.is_upvoted = false;
  //       link.is_downvoted = true;
  //       $scope.$apply();
  //     });
  //   }

  //   $scope.makeGraph = function() {
  //     var force = d3.layout.force().charge(-1200).linkDistance(205).size([$scope.width, $scope.height]);
  
  //     for (var i = 0; i < $scope.links.length; i++) {

  //       $scope.links[i].strokeWidth = 2;
  //       // TODO: uncomment this when the line has strength value.
  //       // $scope.links[i].strokeWidth = Math.round(Math.sqrt($scope.links[i].value))
  //     }
  
  //     for (var i = 0; i < $scope.nodes.length; i++) {
  //       $scope.nodes[i].radius = 10;
  //       // user if first_name defined
  //       if ($scope.nodes[i].first_name != undefined) {
  //         $scope.nodes[i].href = "#/users/" + $scope.nodes[i].id;
  //         $scope.nodes[i].color = "#FFFF66";
  //         $scope.nodes[i].name = $scope.nodes[i].first_name + " " + $scope.nodes[i].last_name
  //       }
  //       // topic if title defined
  //       if ($scope.nodes[i].title != undefined) {
  //         $scope.nodes[i].href = "#/topics/" + $scope.nodes[i].id;
  //         $scope.nodes[i].color = "#00CC66";
  //         $scope.nodes[i].radius *= 6;
  //         $scope.nodes[i].name = $scope.nodes[i].title;
  //       }
  //     }
  
  //     force.nodes($scope.nodes).links($scope.links).theta(1).on("tick", function () {
  //       $scope.$apply()
  //     }).start();
  //   }

  //   $scope.makeGraph();

  // }]);

  // return DeweyApp as a result of function invocation
  return DeweyApp;

};

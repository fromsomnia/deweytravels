var Dewey = (function (Dewey) {

  // controller for all views; other controllers inherit from this
  Dewey.DeweyApp.controller('BaseController', ['$scope', '$location', 'DeweyFactory', function ($scope, $location, DeweyFactory) {

    $scope.queryData = {};
    $scope.graphNodes = DeweyFactory.graphNodes;
    $scope.graphLinks = DeweyFactory.graphLinks;

    $scope.search = function () {
      if (event.keyCode == 13) {
        $location.path('/search/' + $scope.queryData.query);
      }
    };

  }]);

  Dewey.DeweyApp.controller('GraphController', ['$scope', '$controller', 'DeweyFactory', function ($scope, $controller, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });

    $scope.$on('graphUpdated', function() {
      DeweyFactory.getGraphNodesAndLinks().then(function () {
        $scope.graphNodes = DeweyFactory.graphNodes;
        $scope.graphLinks = DeweyFactory.graphLinks;
        $scope.makeGraph();
      });
    });

    function collide (alpha, nodes) {
      var quadtree = d3.geom.quadtree(nodes),
        padding = 1.5;
      return function (d) {
        var r = d.radius + padding,
            nx1 = d.x - r,
            nx2 = d.x + r,
            ny1 = d.y - r,
            ny2 = d.y + r;
        quadtree.visit(function (quad, x1, y1, x2, y2) {
          if (quad.point && (quad.point !== d)) {
            var x = d.x - quad.point.x,
                y = d.y - quad.point.y,
                l = Math.sqrt(x * x + y * y),
                r = d.radius + quad.point.radius + padding;
            if (l < r) {
              l = (l - r) / l * alpha;
              d.x -= x *= l;
              d.y -= y *= l;
              quad.point.x += x;
              quad.point.y += y;
            }
          }
          return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1;
        });
      };
    }

    function cluster (alpha, cluster) {
      if (!cluster) {
        return function (d) { return; };
      }
      return function (d) {
        if (cluster === d) return;
        var x = d.x - cluster.x,
            y = d.y - cluster.y,
            l = Math.sqrt(x * x + y * y),
            r = d.radius + cluster.radius;
        if (l != r) {
          l = (l - r) / l * alpha;
          d.x -= x *= l;
          d.y -= y *= l;
          cluster.x += x;
          cluster.y += y;
        }
      };
    }

    var isDataBinded = false;

    $scope.makeGraph = function () {
      if ($scope.graphNodes) {

        $scope.graphWidth = $('#data-viz svg').width();
        $scope.graphHeight = $('#data-viz svg').height();

        $scope.graphNodes = $scope.graphNodes.slice(0,15)
        _.each($scope.graphNodes, function (node) {
          node.radius = 100 / (($scope.graphNodes.length - 1) / 3.14 - 1) - 2;
        });
        $scope.graphNodes[0].radius = 100;
        $scope.graphNodes[0].x = $scope.graphWidth / 2;
        $scope.graphNodes[0].y = $scope.graphHeight / 2;

        d3.layout.force()
          .nodes($scope.graphNodes.slice(1))
          .size([$scope.graphWidth, $scope.graphHeight])
          .gravity(0.1)
          .charge(0.5)
          .on('tick', function (e) {
            if (!isDataBinded) {
              d3.selectAll('svg .primary, svg .outer')
                .data($scope.graphNodes)
                .enter();
            }

            var count = 0;

            d3.selectAll('svg .primary, svg .outer')
              .each(cluster(e.alpha * e.alpha, $scope.graphNodes[0]))
              .each(collide(0.5, $scope.graphNodes))
              .each(function (d) {
                if (!count) {
                  d.x = $scope.graphWidth / 2;
                  d.y = $scope.graphHeight / 2;
                }
                count++;
              })
              .attr('transform', function (d) {
                return 'translate(' + d.x + ',' + d.y + ')';
              });

          })
          .start();

      }
    };

    $scope.makeGraph();

  }]);

  Dewey.DeweyApp.controller('SearchController', ['$controller', '$scope', 'DeweyFactory', function ($controller, $scope, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.searchResults = DeweyFactory.searchResults;

  }]);

  Dewey.DeweyApp.controller('LoginController', ['$scope', '$location', function ($scope, $location) {

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

  Dewey.DeweyApp.controller('UserController', ['$scope', '$injector', '$controller', 'DeweyFactory', function ($scope, $injector, $controller, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.user = DeweyFactory.user;
    $scope.topicsForUser = DeweyFactory.topicsForUser;
    $scope.topicChoices = DeweyFactory.allTopics;

    $scope.updateTopicsForUser = function () {
      $injector.get('$rootScope').$broadcast('graphUpdated');
      DeweyFactory.getTopicsForUser();
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.topicsForUser = DeweyFactory.topicsForUser;
        });
      }, 500);
    };

    $scope.removeTopicFromUser = function ($event, $tagID) {
      $.post('/users/' + $scope.user.id + '/remove_topic', {
        topic_id: $tagID,
        id: $scope.user.id
      }).done(function (response) {
        $scope.updateTopicsForUser();
      });
    };

    $scope.addTopicToUser = function ($item) {
      $.post('/users/' + $scope.user.id + '/add_topic', {
        topic_id: $item.id,
        id: $scope.user.id
      }).done(function (response) {
        $scope.updateTopicsForUser();
      }).fail(function (response) {
        alert('Fail to add topic to user - please retry.');
      });
    };

  }]);

  Dewey.DeweyApp.controller('TopicController', ['$scope', '$injector', '$controller', 'DeweyFactory', function ($scope, $injector, $controller, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.usersForTopic = DeweyFactory.usersForTopic;
    $scope.topic = DeweyFactory.topic;
    $scope.userChoices = DeweyFactory.allUsers;
    $scope.shouldShowAddUserToTopic = true;

    $scope.updateUsersForTopic = function () {
      $injector.get('$rootScope').$broadcast('graphUpdated');
      DeweyFactory.getUsersForTopic();
      $(typeahead).val('');
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.usersForTopic = DeweyFactory.usersForTopic;
        });
      }, 500);
    };

    $scope.removeUserFromTopic = function ($event, $userID) {
      $.post('/topics/' + $scope.topic.id + '/remove_user', {
        user_id: $userID,
        id: $scope.topic.id
      }).done(function (response) {
        $scope.updateUsersForTopic();
      });
    };

    $scope.addUserToTopic = function ($item) {
      $.post('/topics/' + $scope.topic.id + '/add_user', {
        user_id: $item.id,
        id: $scope.topic.id
      }).done(function (response) {
        $scope.updateUsersForTopic();
      }).fail(function (response) {
        alert('Fail to add user to topic - please retry.');
      });
    };

  }]);

  Dewey.DeweyApp.controller('GroupController', ['$scope', '$injector', '$controller', 'DeweyFactory', function ($scope, $injector, $controller, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });

  }]);


	return Dewey;

})(Dewey);

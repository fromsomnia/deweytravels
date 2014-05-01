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

    function setNodePositions (primaryNode, outerNodes, containerWidth, containerHeight) {

      primaryNode.targetX = containerWidth / 2;
      primaryNode.targetY = containerHeight / 2;

      var hypotenuse = primaryNode.radius + outerNodes[0].radius,
        degrees,
        radians;
      _.each(outerNodes, function (node, i) {
        degrees = 360 / (outerNodes.length) * i;
        radians = degrees * Math.PI / 180;
        node.targetX = primaryNode.targetX + hypotenuse * Math.cos(radians);
        node.targetY = primaryNode.targetY + hypotenuse * Math.sin(radians);
      });

    }

    function orbit (node, step) {
      node.x += (node.targetX - node.x) / step;
      node.y += (node.targetY - node.y) / step;
    }

    $scope.makeGraph = function () {

      if ($scope.graphNodes) {

        $scope.graphWidth = $('#data-viz svg').width();
        $scope.graphHeight = $('#data-viz svg').height();

        var primaryNode = $scope.graphNodes[0],
          numberOfOuterNodes = ($scope.graphNodes.length > 14) ? 14 : $scope.graphNodes.length,
          outerNodes = $scope.graphNodes.slice(1, 1 + numberOfOuterNodes),
          outerNodesPadding = 1,
          primaryNodeRadius = 100,
          outerNodeRadius = primaryNodeRadius / (numberOfOuterNodes / Math.PI - 1);

        primaryNode.radius = primaryNodeRadius;
        _.each(outerNodes, function (node) {
          node.radius = outerNodeRadius;
        });

        setNodePositions(primaryNode, outerNodes, $scope.graphWidth, $scope.graphHeight);

        (function () {
          var nodes = $scope.graphNodes,
            w = $scope.graphWidth,
            h = $scope.graphHeight;
          var force = d3.layout.force()
              .gravity(0.05)
              .charge(function (d, i) { 
                return i ? 0 : -2000; 
              })
              .nodes(nodes)
              .size([w, h]);
          force.start();
          force.on('tick', function (e) {         
            var q = d3.geom.quadtree(nodes),
                i = 0,
                n = nodes.length;
            while (++i < n) {
              orbit(nodes[i], 100);
            }
            $scope.$apply();
          });
        })();

        $scope.primaryNode = primaryNode;
        $scope.outerNodes = outerNodes;
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

var Dewey = (function (Dewey) {

  // controller for all views; other controllers inherit from this
  Dewey.DeweyApp.controller('BaseController', ['$scope', '$location', '$http', 'DeweyFactory', function ($scope, $location, $http, DeweyFactory) {

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
    $scope.graphWidth = 750;
    $scope.graphHeight = 600;

    $scope.$on('graphUpdated', function() {
      DeweyFactory.getGraphNodesAndLinks().then(function () {
        $scope.graphNodes = DeweyFactory.graphNodes;
        $scope.graphLinks = DeweyFactory.graphLinks;
        $scope.makeGraph();
      });
    });

    $scope.makeGraph = function () {
      if ($scope.graphNodes) {
        _.each($scope.graphNodes, function (node) {
          node.radius = (node.first_name) ? 10 : 60;
        });
        // apply force animations on graph
        force = d3.layout
          .force()
          .charge(-1200)
          .linkDistance(205)
          .size([$scope.graphWidth, $scope.graphHeight]);
        force.nodes($scope.graphNodes)
          .links($scope.graphLinks)
          .theta(1)
          .on('tick', function () {
            // updates the data bindings
            $scope.$apply();
          })
          .start();
      }
    };

    $scope.upvote = function (link) {
      $.post('/connections/' + link.connection.id + '/upvote', {
        id: link.connection.id,
        connection_type: link.connectionType
      }).done(function(response) {
        link.is_upvoted = true;
        link.is_downvoted = false;
        $scope.$apply();
      });
    };

    $scope.downvote = function(link) {
      $.post('/connections/' + link.connection.id + '/downvote', {
        id: link.connection.id,
        connection_type: link.connectionType
      }).done(function(response) {
        link.is_upvoted = false;
        link.is_downvoted = true;
        $scope.$apply();
      });
    };

    $scope.$watch('graphNodes', function (newValue, oldValue) {
      $scope.makeGraph();
    });

  }]);

  Dewey.DeweyApp.controller('SearchController', ['$controller', '$scope', '$location', 'DeweyFactory', function ($controller, $scope, $location, DeweyFactory) {

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

  Dewey.DeweyApp.controller('UserController', ['$scope', '$injector', '$controller', '$location', 'DeweyFactory', function ($scope, $injector, $controller, $location, DeweyFactory) {

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

  Dewey.DeweyApp.controller('TopicController', ['$scope', '$injector', '$controller', '$location', 'DeweyFactory', function ($scope, $injector, $controller, $location, DeweyFactory) {

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

	return Dewey;

})(Dewey);

var Dewey = (function (Dewey) {

  // controller for all views; other controllers inherit from this
  Dewey.DeweyApp.controller('BaseController', ['$rootScope', '$http', '$scope', '$location', 'DeweyFactory',
                            function ($rootScope, $http, $scope, $location, DeweyFactory) {

    $scope.queryData = {};
    $scope.graphNodes = DeweyFactory.graphNodes;
    $scope.graphLinks = DeweyFactory.graphLinks;

    $scope.search = function () {
      if (event.keyCode == 13) {
        $location.path('/search/' + $scope.queryData.query);
      }
    };
    if (!$rootScope.current_user_id) {
      $http({
        url: '/sessions/get_auth_token',
        method: "GET"
      }).success(function(data, status, headers, config) {
        $rootScope.current_user_id = data.uid;
      });
    }
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

    $scope.makeGraph = function () {
      if ($scope.graphNodes) {

        $scope.graphWidth = $("#data-viz svg").width();
        $scope.graphHeight = $("#data-viz svg").height();

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

    $scope.$watch('graphNodes', function (newValue, oldValue) {
      $scope.makeGraph();
    });

  }]);

  Dewey.DeweyApp.controller('SearchController', ['$controller', '$scope', 'DeweyFactory', function ($controller, $scope, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.searchResults = DeweyFactory.searchResults;

  }]);

  Dewey.DeweyApp.controller('LoginController', ['$scope', '$injector', '$location', '$http', 'localStorageService', 'DeweyFactory', function ($scope, $injector, $location, $http, localStorageService, DeweyFactory) {
    $scope.loginData = {};
    $scope.facebookLoginButton = true;

    $scope.facebookLogin = function () {
       FB.login(function(response) {
         if (response.authResponse) {
            // may be used in the future for "autoupdate friends list in the background or in scheduler / cron" per Veni
            accessToken = response.authResponse.accessToken;
            FB.api('/me', {fields: ['first_name', 'last_name', 'email', 'picture.type(large)', 'locations']}, function(response) {
              $.post('/sessions/post_facebook_login.json', {
                id: response.id,
                first_name: response.first_name,
                last_name: response.last_name,
                email: response.email,
                access_token: accessToken,
                image_url: response.picture.data.url,
                locations: response.locations
              }).done(function (response) {
                localStorageService.add('dewey_auth_token', response.auth_token);
                FB.api('/me/friends', {fields: ['first_name', 'last_name', 'picture']}, function(fb_response) {
                  $http({
                    url: '/users/add_friends.json',
                    method: "POST",
                    data: { friends: fb_response.data }
                  }).success(function(null_response) {
                    $location.path('/users/' + response.uid);
                  });
                });
              }).fail(function (response) {
                // TODO
              });
            });


         } else {
           console.log('User cancelled login or did not fully authorize.');
         }
       }, {scope: 'email,user_status', return_scopes: true});
    }

    var token = localStorageService.get('dewey_auth_token');
    if (token) {
      $http({
        url: '/sessions/get_auth_token',
        method: "GET"
      }).success(function(data, status, headers, config) {
        $location.path('/users/' + data.uid);
      });
    }

  }]);

  Dewey.DeweyApp.controller('LogoutController', ['$scope', '$injector', '$location', 'localStorageService', 'DeweyFactory', function ($scope, $injector, $location, localStorageService, DeweyFactory) {
    localStorageService.remove('dewey_auth_token');
    $location.path('/');
  }]);

  Dewey.DeweyApp.controller('UserController', ['$scope', '$injector', '$http', '$controller', 'DeweyFactory',
                  function ($scope, $injector, $http, $controller, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.topicSuggestions = DeweyFactory.topicSuggestions;
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
      $http({
        url: '/users/' + $scope.user.id + '/remove_topic',
        method: "POST",
        data: {
          topic_id: $tagID,
          id: $scope.user.id }
      }).success(function(response) {
        $scope.updateTopicsForUser();
      });
    };

    $scope.addTopicToUser = function ($item) {
      $http({
        url: '/users/' + $scope.user.id + '/add_topic',
        data: {
          topic_id: $item.id,
          id: $scope.user.id },
        method: "POST",
      }).success(function (response) {
        $scope.updateTopicsForUser();
      });
    };

    $scope.addTopicSuggestionToUser = function ($item, $index) {
      $scope.topicSuggestions.splice($item, 1);
      $http({
        url: '/users/' + $scope.user.id + '/topic_suggestions',
        data: { previous_suggestions: $scope.topicSuggestions },
        method: "GET",
      }).success(function (response) {
        $scope.topicSuggestions = response;
      });

      $scope.addTopicToUser($item);
    };

  }]);

  Dewey.DeweyApp.controller('TopicController', ['$scope', '$injector', '$controller', '$http', 'DeweyFactory',
                            function ($scope, $injector, $controller, $http, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });

    $scope.userSuggestions = DeweyFactory.userSuggestions;
    $scope.usersForTopic = DeweyFactory.usersForTopic;
    $scope.topic = DeweyFactory.topic;
    $scope.userChoices = DeweyFactory.allUsers;
    $scope.shouldShowAddUserToTopic = true;
    $scope.newTopic = {};

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
      $http({
        url: '/topics/' + $scope.topic.id + '/remove_user',
        data: {
          user_id: $item.id,
          id: $scope.topic.id },
        method: "POST",
      }).success(function (response) {
        $scope.updateUsersForTopic();
      });
    };

    $scope.addUserToTopic = function ($item) {
      $http({
        url: '/topics/' + $scope.topic.id + '/add_user',
        data: {
          user_id: $item.id,
          id: $scope.topic.id },
        method: "POST",
      }).success(function (response) {
        $scope.updateUsersForTopic();
      });
    };

    $scope.addUserSuggestionToTopic = function ($item, $index) {
      $scope.userSuggestions.splice($item, 1);
      $http({
        url: '/topics/' + $scope.topic.id + '/user_suggestions',
        data: { previous_suggestions: $scope.userSuggestions },
        method: "GET",
      }).success(function (response) {
        $scope.userSuggestions = response;
      });

      $scope.addUserToTopic($item);
    };

   $scope.updateTopics = function () {
      $injector.get('$rootScope').$broadcast('graphUpdated');
      //TODO: make newly added topics always show instead of
      // just most connected
      DeweyFactory.getGraphNodesAndLinks();
      $('#new-topic').val('');
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.graphNodes = DeweyFactory.graphNodes;
          $scope.graphLinks = DeweyFactory.graphLinks;
        });
      }, 500);
    };

    $scope.addSubtopicToTopic = function () {
      if (event.keyCode == 13) {
        $http({
          url: '/topics.json',
          data: {
            topic: {
              parent_id: $scope.topic.id,
              title: $scope.newTopic.title
            }
          },
          method: "POST",
        }).success(function (response) {
          $scope.updateTopics();
        });
      }
    };

      


  }]);

	return Dewey;

})(Dewey);

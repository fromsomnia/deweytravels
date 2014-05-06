var Dewey = (function (Dewey) {

  // controller for all views; other controllers inherit from this
  Dewey.DeweyApp.controller('BaseController', ['$rootScope', '$http', '$scope', '$location', 'DeweyFactory', function ($rootScope, $http, $scope, $location, DeweyFactory) {

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

        // reorders graph nodes so that the first node is the center node
        (function () {
          var index;
          if ($scope.user) {
            _.each($scope.graphNodes, function (node, i) {
              if (node.first_name === $scope.user.first_name
                && node.last_name === $scope.user.last_name)
              {
                index = i;
              }
            });
          } else if ($scope.topic) {
            _.each($scope.graphNodes, function (node, i) {
              if (node.title === $scope.topic.title)
              {
                index = i;
              }
            });
          }
          var restOfNodes = (function () {
            return $scope.graphNodes.slice(0, index).concat($scope.graphNodes.slice(index + 1));
          })();
          $scope.graphNodes = [$scope.graphNodes[index]].concat(restOfNodes);
        })();

        // set categories for nodes
        (function () {
          _.each($scope.graphNodes, function (node) {
            if (node.title) {
              node.category = 'topic';
            } else if (node.first_name && node.last_name) {
              node.category = 'user';
            }
          });
        })();

        var primaryNode = $scope.graphNodes[0],
          numberOfOuterNodes = ($scope.graphNodes.length > 14) ? 14 : $scope.graphNodes.length - 1,
          outerNodes = $scope.graphNodes.slice(1, 1 + numberOfOuterNodes),
          outerNodesPadding = 1,
          primaryNodeRadius = 100,
          outerNodeRadius = primaryNodeRadius / (numberOfOuterNodes / Math.PI - 1);

        primaryNode.radius = primaryNodeRadius;

        if (outerNodeRadius > primaryNodeRadius || outerNodeRadius < 0) {
          outerNodeRadius = primaryNodeRadius * 2 / 3;
        }

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

  Dewey.DeweyApp.controller('UserController', ['$scope', '$injector', '$http', '$controller', 'DeweyFactory', function ($scope, $injector, $http, $controller, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.topicSuggestions = DeweyFactory.topicSuggestions;
    $scope.user = DeweyFactory.user;
    $scope.topicsForUser = DeweyFactory.topicsForUser;
    $scope.topicChoices = DeweyFactory.allTopics;
    $scope.sendFacebookMessage = function () {
      console.log($scope.user);
      FB.ui({
        method: 'send',
        to: $scope.user.fb_id,
        link: 'http://team-dewey-website.herokuapp.com/dev'
      });
    };

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

    $scope.shuffleTopicSuggestionsToUser = function () {
      $http({
        url: '/users/' + $scope.user.id + '/topic_suggestions',
        method: "GET",
      }).success(function (response) {
        $scope.topicSuggestions = response;
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

  Dewey.DeweyApp.controller('TopicController', ['$scope', '$injector', '$controller', '$http', 'DeweyFactory', function ($scope, $injector, $controller, $http, DeweyFactory) {

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

  Dewey.DeweyApp.controller('GroupController', ['$scope', '$injector', '$controller', 'DeweyFactory', function ($scope, $injector, $controller, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });

  }]);

	return Dewey;

})(Dewey);

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
    $scope.facebookLogout = function () {
      FB.logout(function(response) {
        // logs out of facebook, then logs out of Dewey
        $location.path('/logout');
      });
    };

    $scope.facebookShare = function () {
      FB.api(
          "/" + $scope.user.fb_id + "/feed",
          "POST",
          {
                  message: "See where your friends have traveled!",
                  link: "http://www.deweytravels.com"
          },
          function (response) {
            if (response && !response.error) {
              console.log("Successfully shared to Facebook");
              alert("Thanks for sharing Dewey on Facebook!");
            }
            else {
              console.log("Error sharing on Facebook");
            }
          }
      );
    };

  }]);

  Dewey.DeweyApp.controller('GraphController', ['$scope', '$controller', 'DeweyFactory', function ($scope, $controller, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });

    $scope.clusters = [];
    $scope.allNodes = [];

    function reloadGraph () {
      DeweyFactory.getGraphNodesAndLinks().then(function () {
        $scope.graphNodes = DeweyFactory.graphNodes;
        $scope.graphLinks = DeweyFactory.graphLinks;

        initInitialGraph();
        $scope.makeGraph();
      });
    };
    $scope.$on('graphUpdated', function() {
      reloadGraph();
    });
    $scope.$on('updateTopicsForUser', function() {
      $scope.clusters = [];
    });
    reloadGraph();

    function initInitialGraph () {
      setCategoriesForNodes($scope.graphNodes);
      var maxOuterNodes = 14, 
        numberOfOuterNodes = ($scope.graphNodes.length > maxOuterNodes) ? maxOuterNodes : $scope.graphNodes.length - 1;
      $scope.allNodes = $scope.allNodes.concat($scope.graphNodes);
      $scope.clusters[0] = {
        primaryNode: $scope.graphNodes[$scope.graphNodes.length - 1],
        outerNodes: $scope.graphNodes.slice(0, numberOfOuterNodes)
      };
    }

    function setNodePositions (clusters, width, height) {
      var center = {
        x: width / 2,
        y: height / 2
      };
      clusters.forEach(function (cluster, i) {
        var hypotenuse = cluster.primaryNode.radius + ((cluster.outerNodes.length) ? cluster.outerNodes[0].radius : 0),
          degrees,
          radians;
        if (i === 0) {
          cluster.primaryNode.targetX = center.x;
          cluster.primaryNode.targetY = center.y;
        } else {
          var radians = (360 / (clusters.length) * (i - 1)) * Math.PI / 180;
          cluster.primaryNode.targetX = center.x + 250 * Math.cos(radians);
          cluster.primaryNode.targetY = center.y + 250 * Math.sin(radians);
        }
        cluster.outerNodes.forEach(function (node, i) {
          degrees = 360 / (cluster.outerNodes.length) * i;
          radians = degrees * Math.PI / 180;
          node.targetX = cluster.primaryNode.targetX + hypotenuse * Math.cos(radians);
          node.targetY = cluster.primaryNode.targetY + hypotenuse * Math.sin(radians);
        });
      });
    }

    function setNodeRadii (clusters) {
      var maxOuterNodes = 14;
      clusters.forEach(function (cluster, i) {
        var numberOfOuterNodes = (cluster.outerNodes.length > maxOuterNodes) ? maxOuterNodes : cluster.outerNodes.length,
          primaryNodeRadius;
        if (i === 0) {
          primaryNodeRadius = 65;
        } else {
          primaryNodeRadius = 50;
        }
        var outerNodeRadius = (function () {
          var radius = primaryNodeRadius / (numberOfOuterNodes / Math.PI - 1);
          if (radius > primaryNodeRadius || radius < 0) {
            radius = primaryNodeRadius * 2 / 3;
          }
          return radius;
        })();
        cluster.primaryNode.radius = primaryNodeRadius;
        cluster.outerNodes.forEach(function (node) {
          node.radius = outerNodeRadius;
        });
      });
    }

    function orbit (node, step) {
      node.x += (node.targetX - node.x) / step;
      node.y += (node.targetY - node.y) / step;
    }

    // reorders graph nodes so that the first node is the center node
    function sortNodes (nodes) {
      var index;
      if ($scope.user) {
        _.each(nodes, function (node, i) {
          if (node.first_name === $scope.user.first_name
            && node.last_name === $scope.user.last_name)
          {
            index = i;
          }
        });
      } else if ($scope.topic) {
        _.each(nodes, function (node, i) {
          if (node.title === $scope.topic.title)
          {
            index = i;
          }
        });
      }
      var restOfNodes = (function () {
        return nodes.slice(0, index).concat(nodes.slice(index + 1));
      })();
      return [nodes[index]].concat(restOfNodes);
    }

    function setCategoriesForNodes (nodes) {
      nodes.forEach(function (node) {
       if (node.title) {
          node.category = 'topic';
        } else if (node.first_name && node.last_name) {
          node.category = 'user';
        }
      });
    }

    function animateNodes (nodes, width, height) {
      var force = d3.layout.force()
          .gravity(0.05)
          .charge(-100)
          .nodes(nodes)
          .size([width, height]);
      force.start();
      force.on('tick', function (e) {
        nodes.forEach(function (node) {
          orbit(node, 100);
        });
        $scope.$apply();
      });
    }

    $scope.focusOnCluster = function (clusterIndex) {
      var extractedCluster = $scope.clusters.splice(clusterIndex, 1)[0];
      $scope.clusters.unshift(extractedCluster);
      $scope.makeGraph();
    }
        
    $scope.expandNode = function (node) {
      if (node.category !== 'topic') {
        return;
      }
      DeweyFactory.getGraphNodesForUserAndTopic($scope.user.id, node.id)
        .then(function() {
          setCategoriesForNodes(DeweyFactory.expandedGraphNodes);
          var cluster = {
            primaryNode: DeweyFactory.expandedGraphNodes[DeweyFactory.expandedGraphNodes.length - 1],
            outerNodes: DeweyFactory.expandedGraphNodes.slice(0,DeweyFactory.expandedGraphNodes.length - 1)
          };
          for(var i = 0; i < $scope.clusters.length; i++){
            var temp = $scope.clusters[i];
            if(temp['primaryNode'].category == 'topic'){
              if(temp['primaryNode'].id == cluster['primaryNode'].id){
                $scope.focusOnCluster(i);
                return;
              }
            }
          }
          $scope.clusters.unshift(cluster);
          $scope.allNodes = $scope.allNodes.concat(DeweyFactory.expandedGraphNodes);
          $scope.makeGraph();
        });
    };

    $scope.viewAll = function (clusterIndex) {
      $scope.clusters[clusterIndex].outerNodes = $scope.clusters[clusterIndex].outerNodes.concat($scope.graphNodes.slice($scope.clusters[clusterIndex].outerNodes.length, $scope.graphNodes.length - 1));
      $scope.makeGraph();
    };

    $scope.makeGraph = function () {
      if ($scope.clusters.length) {

        $scope.graphWidth = $('#data-viz svg').width();
        $scope.graphHeight = $('#data-viz svg').height();

        setNodeRadii($scope.clusters);
        setNodePositions($scope.clusters, $scope.graphWidth, $scope.graphHeight);
        animateNodes($scope.allNodes, $scope.graphWidth, $scope.graphHeight);

      }
    };


  }]);

  Dewey.DeweyApp.controller('SearchController', ['$controller', '$scope', 'DeweyFactory', function ($controller, $scope, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.searchResults = DeweyFactory.searchResults;

  }]);

  Dewey.DeweyApp.controller('BaseLoginController',
                  ['$scope', 'currentUser', '$rootScope', '$analytics', '$injector', '$location', '$http', 'localStorageService', 'DeweyFactory',
                  function ($scope, currentUser, $rootScope, $analytics, $injector, $location, $http, localStorageService, DeweyFactory) {
    $scope.loginData = {};
    $scope.facebookLoginButton = true;

    $scope.facebookLogin = function () {
       $analytics.eventTrack('click_facebook_login_button');

       FB.login(function(response) {
         if (response.authResponse) {
          $analytics.eventTrack('facebook_login_success');
          var authToken = response.authResponse.accessToken;
          $.post('/sessions/post_try_facebook_login.json', {
            id: response.authResponse.userID
          }).done(function (response) {
            $scope.$apply(function () {
              $scope.loginDeweyUser(response.auth_token, response.uid, { 'type': 'facebook', 'uid': response.uid });
            });
          }).fail(function(response) {
            $scope.signupFacebookUser(authToken);
          });
         } else {
           $analytics.eventTrack('facebook_login_failed');
           console.log('User cancelled login or did not fully authorize.');
         }
       }, {scope: 'email,user_status,publish_actions', return_scopes: true});
    };

    $scope.loginDeweyUser = function (authToken, deweyUid, analyticsPayload) {
      localStorageService.add('dewey_auth_token', authToken);
      $analytics.eventTrack('login_user', analyticsPayload);

      if (!$rootScope.isLoggedIn) {
        currentUser.get(function(data) {
          if (data.uid) {
            $rootScope.isLoggedIn = true; 
            $rootScope.currentUserId = data.uid;
          }
          else {
            $rootScope.isLoggedIn = false;  
          }
        });
      }
      $location.path('/users/' + deweyUid);
    };

    $scope.signupFacebookUser = function (accessToken) {
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
          $analytics.eventTrack('signup_user', { 'uid': response.uid });

          localStorageService.add('dewey_auth_token', response.auth_token);
          FB.api('/me/friends', {fields: ['first_name', 'last_name', 'picture']}, function(fb_response) {
            $http({
              url: '/users/add_friends.json',
              method: "POST",
              data: { friends: fb_response.data }
            }).success(function(null_response) {
              $scope.loginDeweyUser(response.auth_token, response.uid, { 'type': 'facebook', 'uid': response.uid })
            });
          });
        }).fail(function (response) {
          $analytics.eventTrack('signup_user_failed');
          // TODO
        });
      });
    };
  }]);

  Dewey.DeweyApp.controller('LoginController', ['$scope', '$controller', '$injector', '$location', '$http', 'localStorageService', 'DeweyFactory', function ($scope, $controller, $injector, $location, $http, localStorageService, DeweyFactory) {
    $controller('BaseLoginController', {
      $scope: $scope
    });

    var token = localStorageService.get('dewey_auth_token');
    if (token) {
      $http({
        url: '/sessions/get_auth_token',
        method: "GET"
      }).success(function(data, status, headers, config) {
        $scope.loginDeweyUser(token, data.uid, { 'type': 'auto_login', 'uid': data.uid });
      });
    }
  }]);

  Dewey.DeweyApp.controller('LogoutController', ['$scope', '$rootScope', '$analytics', '$injector', '$location', 'localStorageService', 'DeweyFactory', function ($scope, $rootScope, $analytics, $injector, $location, localStorageService, DeweyFactory) {
    localStorageService.remove('dewey_auth_token');

    $rootScope.isLoggedIn = false; 
    $analytics.eventTrack('logout_user', { 'uid': $rootScope.currentUserId })
    $rootScope.currentUserId = null;


    $location.path('/');
  }]);

  Dewey.DeweyApp.controller('UserController',
                        ['$scope', '$rootScope', '$analytics', '$injector', '$http', '$controller', 'DeweyFactory',
                         function ($scope, $rootScope, $analytics, $injector, $http, $controller, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });

    if ($rootScope.isLoggedIn) {
      DeweyFactory.getTopicsForUser().then(function() {
        $scope.topicsForUser = DeweyFactory.topicsForUser;
      });

      DeweyFactory.getAllTopics().then(function() {
        $scope.topicChoices = DeweyFactory.allTopics;
      });
      DeweyFactory.getTopicSuggestions().then(function() {
        $scope.topicSuggestions = DeweyFactory.topicSuggestions;
      });
    }

    $scope.user = DeweyFactory.user;

    $scope.sendFacebookMessage = function () {
      FB.ui({
        method: 'send',
        to: $scope.user.fb_id,
        link: 'http://www.deweytravels.com'
      });
    };

    function setCategoriesForNodes (nodes) {
      nodes.forEach(function (node) {
       if (node.title) {
          node.category = 'topic';
        } else if (node.first_name && node.last_name) {
          node.category = 'user';
        }
      });
    }

    $scope.updateTopicsForUser = function () {
      $injector.get('$rootScope').$broadcast('updateTopicsForUser');
      $injector.get('$rootScope').$broadcast('graphUpdated');
      DeweyFactory.getTopicsForUser();
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.topicsForUser = DeweyFactory.topicsForUser;
        });
      }, 500);
    };


    $scope.removeTopicFromUser = function ($tagID) {
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
      $analytics.eventTrack('shuffle_topic_suggestions_to_user', { 'uid': $scope.user.id });
      $http({
        url: '/users/' + $scope.user.id + '/topic_suggestions',
        method: "GET",
      }).success(function (response) {
        $scope.topicSuggestions = response;
      });
    };

    $scope.addTopicSuggestionToUser = function ($item, $index) {
      $analytics.eventTrack('add_topic_suggestion_to_user',
                            { 'uid': $scope.user.id, 'tid': $item.id });
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

  Dewey.DeweyApp.controller('TopicController',
                ['$scope', '$analytics', '$rootScope', '$injector', '$controller', '$http', 'DeweyFactory',
                 function ($scope, $analytics, $rootScope, $injector, $controller, $http, DeweyFactory) {
    $controller('BaseController', {
      $scope: $scope
    });

    $scope.topic = DeweyFactory.topic;
    DeweyFactory.getTopicsForTopic().then(function() {
      $scope.topicsForTopic = DeweyFactory.topicsForTopic;
    });

    $scope.isUserAnExpert = false;

    if ($rootScope.isLoggedIn) {
      DeweyFactory.getUsersForTopic().then(function() {
        $scope.usersForTopic = DeweyFactory.usersForTopic;

        $scope.usersForTopic.forEach(function(element, index, array) {
          if (element.id == $rootScope.currentUserId) {
            $scope.isUserAnExpert = true;
          }
        });
      });

      DeweyFactory.getAllUsers().then(function () {
        $scope.userChoices = DeweyFactory.allUsers;
      });
 
      DeweyFactory.getUserSuggestions().then(function () {
        $scope.userSuggestions = DeweyFactory.userSuggestions;
      });
    }

    $scope.shouldShowAddUserToTopic = true;
    $scope.newTopic = {};

    $scope.updateUsersForTopic = function () {
      $injector.get('$rootScope').$broadcast('graphUpdated');
      DeweyFactory.getUsersForTopic();
      setTimeout(function () {
        $scope.$apply(function () {
          $scope.usersForTopic = DeweyFactory.usersForTopic;
        });
      }, 500);
    };

    $scope.removeUserFromTopic = function ($userID) {
      $http({
        url: '/topics/' + $scope.topic.id + '/remove_user',
        data: {
          user_id: $userID,
          id: $scope.topic.id },
        method: "POST",
      }).success(function (response) {
        $scope.updateUsersForTopic();
      });
    };

    $scope.addSelfToTopic = function () {
      $analytics.eventTrack('add_self_to_topic', { 'tid': $scope.topic.id, 'uid': $rootScope.currentUserId });
      $http({
        url: '/topics/' + $scope.topic.id + '/add_user',
        data: {
          user_id: $rootScope.currentUserId,
          id: $scope.topic.id },
        method: "POST",
      }).success(function (response) {
        $scope.updateUsersForTopic();
      });
    }

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

      $analytics.eventTrack('add_user_suggestion_to_topic',
                            { 'uid': $item.id, 'tid': $scope.topic.id });
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

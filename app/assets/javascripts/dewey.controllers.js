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
  }]);

  Dewey.DeweyApp.controller('GraphController', ['$scope', '$controller', 'DeweyFactory', function ($scope, $controller, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });

    function reloadGraph () {
      DeweyFactory.getGraphNodesAndLinks().then(function () {
        $scope.graphNodes = DeweyFactory.graphNodes;
        $scope.graphLinks = DeweyFactory.graphLinks;

        $scope.makeGraph();
      });
    };
    $scope.$on('graphUpdated', function() {
      reloadGraph();
    });
    reloadGraph();

    function setNodePositions (clusters, width, height) {
      var center = {
        x: width / 2,
        y: height / 2
      };
      clusters.forEach(function (cluster, i) {
        var hypotenuse = cluster.primaryNode.radius + cluster.outerNodes[0].radius,
          degrees,
          radians;
        if (i === 0) {
          cluster.primaryNode.targetX = center.x;
          cluster.primaryNode.targetY = center.y;
        } else {
          cluster.primaryNode.targetX = center.x + (clusters[0].primaryNode.radius + clusters[0].outerNodes[0].radius) * 2.5;
          cluster.primaryNode.targetY = center.y;
        }
        cluster.outerNodes.forEach(function (node, i) {
          degrees = 360 / (cluster.outerNodes.length) * i;
          radians = degrees * Math.PI / 180;
          node.targetX = cluster.primaryNode.targetX + hypotenuse * Math.cos(radians);
          node.targetY = cluster.primaryNode.targetY + hypotenuse * Math.sin(radians);
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
          .charge(function (d, i) { 
            return i ? 0 : -2000; 
          })
          .nodes(nodes)
          .size([width, height]);
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
    }

    $scope.makeGraph = function () {
      if ($scope.graphNodes) {

        var jsonString = '[{"id":177,"first_name":"Jennifer","last_name":"Olivera","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t1.0-1/p50x50/1510994_637280516326450_940143971_t.jpg","title":null,"fb_id":"100001335218353","graph_id":481944885,"auth_token":"38ac9975a7e0da5ecc6580095f3ec132","name":"Jennifer Olivera"},{"id":46,"first_name":"Wilfred","last_name":"Manzano","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash3/t1.0-1/c23.7.84.84/s50x50/1013666_10151712882434479_1936848920_s.jpg","title":null,"fb_id":"646904478","graph_id":481944885,"auth_token":"acfd83598a82f83e702220f2d104e413","name":"Wilfred Manzano"},{"id":94,"first_name":"Anh","last_name":"Truong","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash3/t1.0-1/c0.0.50.50/p50x50/1462856_10201761053647891_278729930_t.jpg","title":null,"fb_id":"1227720370","graph_id":481944885,"auth_token":"9963a63d2cdcfe5f0f9c68be23023e24","name":"Anh Truong"},{"id":3,"first_name":"Kent","last_name":"Go","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-frc3/t1.0-1/p50x50/181009_10102479499993953_180996916_t.jpg","title":null,"fb_id":"2261641","graph_id":481944885,"auth_token":"30fbff4d70263b5f0163c41fc4d02ea1","name":"Kent Go"},{"id":47,"first_name":"Aurora Victoria","last_name":"David","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-frc3/t1.0-1/c0.8.50.50/p50x50/10277869_10154108098805634_8155738829607811325_t.jpg","title":null,"fb_id":"647410633","graph_id":481944885,"auth_token":"43f43eeb8b9f64be67ad125dc51bb13b","name":"Aurora Victoria David"},{"id":122,"first_name":"Abraham","last_name":"Cabangbang","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/t1.0-1/c35.2.102.102/s50x50/1150874_10200371267914883_1925929891_a.jpg","title":null,"fb_id":"1550730037","graph_id":481944885,"auth_token":"1d41dc32011f664be24434032cf171ba","name":"Abraham Cabangbang"},{"id":114,"first_name":"Dindin","last_name":"Baniqued","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/t1.0-1/p50x50/10269519_10201920255394256_7864762514959439201_t.jpg","title":null,"fb_id":"1420361603","graph_id":481944885,"auth_token":"053cbab38919956a81ebef6e5b1c7a6a","name":"Dindin Baniqued"},{"id":188,"first_name":"Phuong","last_name":"Nguyen","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/t1.0-1/p50x50/1501818_493351550783873_1677805840_t.jpg","title":null,"fb_id":"100003270974363","graph_id":481944885,"auth_token":"3ebb960c0e3bc36681ac91637532cf3a","name":"Phuong Nguyen"},{"id":27,"first_name":"Andrew","last_name":"Loo","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/t1.0-1/c3.0.50.50/p50x50/1604719_10152786076223975_768494706298070599_s.jpg","title":null,"fb_id":"562093974","graph_id":481944885,"auth_token":"0180f55bd6d8ae40877cf1a8249b6d6a","name":"Andrew Loo"},{"id":26,"first_name":"Sherlene","last_name":"Chatterji","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/t1.0-1/c13.0.50.50/p50x50/1011038_10152270077582803_1520637736_s.jpg","title":null,"fb_id":"561332802","graph_id":481944885,"auth_token":"0a10e0ac8652f376b91e38277f50c76f","name":"Sherlene Chatterji"},{"id":131,"first_name":"James","last_name":"Huỳnh","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-frc3/t1.0-1/c9.0.50.50/p50x50/10312390_10202768104717713_1398869491074373694_s.jpg","title":null,"fb_id":"1652996761","graph_id":481944885,"auth_token":"131e2995420b7553f2976de8fc3129ce","name":"James Huỳnh"},{"id":81,"first_name":"RMi","last_name":"Flores","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t1.0-1/p50x50/1509824_10201860127081019_3602488489722225198_t.jpg","title":null,"fb_id":"1118364916","graph_id":481944885,"auth_token":"2bf626e81e3d8ca52a76fca66c7b6984","name":"RMi Flores"},{"id":79,"first_name":"Ina","last_name":"Tiangco","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/t1.0-1/c15.0.50.50/p50x50/1522037_2173087600782_559692479_s.jpg","title":null,"fb_id":"1054530458","graph_id":481944885,"auth_token":"c1496a8898a1563f4202bebe4b460cbe","name":"Ina Tiangco"},{"id":4,"first_name":"Tony","last_name":"Tran","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t1.0-1/p50x50/1656156_10152376132211970_8982607493696831402_t.jpg","title":null,"fb_id":"500876969","graph_id":481944885,"auth_token":"3124136c408723a9c7fa8ce1ffb17ed7","name":"Tony Tran"},{"id":69,"first_name":"Jessica","last_name":"Jin","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-frc3/t1.0-1/c13.0.50.50/p50x50/10258806_10152791870234307_7009239051673622428_s.jpg","title":null,"fb_id":"800029306","graph_id":481944885,"auth_token":"75de2707f50940eb227b7ce09d9dfe77","name":"Jessica Jin"},{"id":98,"first_name":"Debra","last_name":"Pacio","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/v/t1.0-1/c13.0.50.50/…ff94fe2bec&oe=53C8ECDB&__gda__=1405555376_a698a43a83dcb1976117f92d3bbbdbda","title":null,"fb_id":"1300300269","graph_id":481944885,"auth_token":"6898d3096a708e5537973c569fd3880a","name":"Debra Pacio"},{"id":18,"first_name":"Fabian","last_name":"Bock","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash3/t1.0-1/c7.7.91.91/s50x50/1098175_10151584429863285_2079852159_s.jpg","title":null,"fb_id":"547148284","graph_id":481944885,"auth_token":"dfbc5c43de6d1ff80efb58a4bcbdcd26","name":"Fabian Bock"},{"id":161,"first_name":"Eugene","last_name":"Pulvera","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash3/t1.0-1/p50x50/1781969_740158949351339_1856811133_t.jpg","title":null,"fb_id":"100000717218013","graph_id":481944885,"auth_token":"d3333429e9d5f205b52fa1d24f3e94a6","name":"Eugene Pulvera"},{"id":83,"first_name":"Trent","last_name":"Woodward","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-frc3/t1.0-1/c0.0.50.50/p50x50/1175490_10202624958962318_4745719238035410474_t.jpg","title":null,"fb_id":"1147757463","graph_id":481944885,"auth_token":"9459877918b37be1deb177802f5414b2","name":"Trent Woodward"},{"id":176,"first_name":"Jason","last_name":"Yang","email":null,"phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/t1.0-1/p50x50/1964911_623941017659127_1547462063_t.jpg","title":null,"fb_id":"100001297040371","graph_id":481944885,"auth_token":"562c5238b84b2c048b96fd0fd384c0ac","name":"Jason Yang"},{"id":1,"first_name":"John","last_name":"Pulvera","email":"john.nino.pulvera@gmail.com","phone":null,"username":null,"password":null,"password_enc":null,"salt":null,"image_url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-frc1/t1.0-1/s200x200/252231_1002029915278_1941483569_n.jpg","title":null,"fb_id":"100002827398123","graph_id":481944885,"auth_token":"e26f4074e8bd3f964b495045d4cab054","name":"John Pulvera"}]';
        var otherNodes = JSON.parse(jsonString);

        var nodes = sortNodes($scope.graphNodes);
        setCategoriesForNodes(nodes);

        var maxOuterNodes = 14, 
          numberOfOuterNodes = (nodes.length > maxOuterNodes) ? maxOuterNodes : nodes.length - 1,
          outerNodesPadding = 1;

        $scope.graphWidth = $('#data-viz svg').width();
        $scope.graphHeight = $('#data-viz svg').height();
        $scope.clusters = [];
        $scope.clusters[0] = {
          primaryNode: nodes[0],
          outerNodes: nodes.slice(1, 1 + numberOfOuterNodes)
        };

        $scope.clusters[1] = {
          primaryNode: otherNodes[0],
          outerNodes: otherNodes.slice(1, 1 + numberOfOuterNodes)
        };

        $scope.clusters.forEach(function (cluster, i) {
          var primaryNodeRadius;
          if (i === 0) {
            primaryNodeRadius = 100;
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

        $scope.expandNode = function () {
          // add another cluster to visualization
          console.log('expand node!');
        };

        $scope.viewAll = function () {
          // show all nodes
          console.log('view all');
        };

        setNodePositions($scope.clusters, $scope.graphWidth, $scope.graphHeight);
        animateNodes(nodes.concat(otherNodes), $scope.graphWidth, $scope.graphHeight);

      }
    };


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

    DeweyFactory.getTopicsForUser().then(function() {
      $scope.topicsForUser = DeweyFactory.topicsForUser;
    });

    DeweyFactory.getAllTopics().then(function() {
      $scope.topicChoices = DeweyFactory.allTopics;
    });
    DeweyFactory.getTopicSuggestions().then(function() {
      $scope.topicSuggestions = DeweyFactory.topicSuggestions;
    });

    $scope.user = DeweyFactory.user;

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

    $scope.topic = DeweyFactory.topic;

    DeweyFactory.getUsersForTopic().then(function() {
      $scope.usersForTopic = DeweyFactory.usersForTopic;
    });

    DeweyFactory.getAllUsers().then(function () {
      $scope.userChoices = DeweyFactory.allUsers;
    });
 
    DeweyFactory.getUserSuggestions().then(function () {
      $scope.userSuggestions = DeweyFactory.userSuggestions;
    });

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

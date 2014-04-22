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

  Dewey.DeweyApp.controller('SearchController', ['$controller', '$scope', 'DeweyFactory', function ($controller, $scope, DeweyFactory) {

    $controller('BaseController', {
      $scope: $scope
    });
    $scope.searchResults = DeweyFactory.searchResults;

  }]);

  Dewey.DeweyApp.controller('LoginController', ['$scope', '$injector', '$location', '$http', 'localStorageService', 'DeweyFactory', function ($scope, $injector, $location, $http, localStorageService, DeweyFactory) {
    $scope.loginData = {};
    $scope.googleLoginButton = true;
    $scope.deweyLoginButton = true;
    $scope.deweyRegisterButton = true;
    $scope.showDeweyForm = false;
    $scope.showDeweyRegisterForm = false;

    $.get('/sessions/google_api', function (response) {
      $scope.client_id = response.client_id;
    });

    $scope.googleLogin = function () {
      gapi.auth.authorize({
              client_id: $scope.client_id,
              scope: 'https://www.google.com/m8/feeds https://www.googleapis.com/auth/contacts https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/plus.me'},
              $scope.handleAuthResult);

    };

    $scope.handleAuthResult = function (authResult) {
      gapi.client.load('oauth2', 'v2', function () {
        gapi.client.oauth2.userinfo.get().execute(function(resp) {
          var email = resp.email;
          
          $.post('/sessions/post_try_google_login.json', {
            email: email
          }).done(function (response) {
            localStorageService.add('dewey_auth_token', response.auth_token);

            $scope.$apply(function() {
              $location.path('/search');
            });
          }).fail(function (response) {
            $scope.loginData.email = resp.email;
            $scope.loginData.lastName = resp.family_name;
            $scope.loginData.firstName = resp.given_name;
            $scope.loginData.imageUrl = resp.picture;
            $scope.loginData.googAccessToken = authResult.access_token;
            $scope.loginData.googExpiresTime = Date.now() + authResult.expires_in * 1000;
            $scope.showDeweyForm = false;
            $scope.showGoogleForm = true;
            $scope.$apply();
          });
        });
      });
    }

    $scope.showDeweyLogin = function () {
      $scope.showDeweyForm = !$scope.showDeweyForm;
      $scope.showGoogleForm = false;
      $scope.googleLoginButton = false;
      $scope.deweyLoginButton = false;
      $scope.deweyRegisterButton = false;
      $scope.loginData.googAccessToken = '';
      $scope.loginData.googExpiresTime = '';
    }

    $scope.showDeweyRegister = function () {
      $scope.showDeweyRegisterForm = !$scope.showDeweyRegisterForm;
      $scope.showGoogleForm = false;
      $scope.googleLoginButton = false;
      $scope.deweyLoginButton = false;
      $scope.deweyRegisterButton = false;
    }

    var token = localStorageService.get('dewey_auth_token');
    if (token) {
      $http({
        url: '/sessions/get_auth_token',
        method: "GET"
      }).success(function(data, status, headers, config) {
        $location.path('/search');
      });
    }

    $scope.getGoogleContacts = function (accessToken, nextPath) {
      $.getJSON('https://www.google.com/m8/feeds/contacts/default/full/?access_token=' + 
                 accessToken + "&max-results=2000&alt=json&callback=?",
                function(result) {
        var contacts = [];
        raw_entries = result['feed']['entry'];
        raw_entries.forEach(function(element, index, array) {
          var emails = element['gd$email'];
          var email = '';
          if (emails && emails.length > 0 && 'address' in emails[0])
            email = emails[0]['address'];
          contacts.push({ title: element['title']['$t'],
                         email: email
                        });
        });

        $http({
          url: '/users/import_google_contacts.json',
          method: "POST",
          data: { contacts: contacts }
        }).success(function(data, status, headers, config) {
          $location.path(nextPath);
        });
      });
    }

    // ...
    $scope.login = function () {

      $.post('/sessions/post_login.json', {
        email: $scope.loginData.email,
        password: $scope.loginData.password,
        image_url: $scope.loginData.imageUrl,
        last_name: $scope.loginData.firstName,
        first_name: $scope.loginData.lastName,
        goog_access_token: $scope.loginData.googAccessToken,
        goog_expires_time: $scope.loginData.googExpiresTime,
      }).done(function (response) {
        localStorageService.add('dewey_auth_token', response.auth_token);

        if ($scope.loginData.googAccessToken) {
          $scope.getGoogleContacts($scope.loginData.googAccessToken,
                                   '/search');
        } else {
          $scope.$apply(function() {
            $location.path('/search');
          });
        }

      }).fail(function (response) {
        delete $window.sessionStorage.token;
        alert("Invalid Socialcast email and password - please retry.");
      });
    }

    $scope.renderDefaultLogin = function () {
      $scope.deweyLoginButton = true;
      $scope.googleLoginButton = true;
      $scope.deweyRegisterButton = true;
      $scope.showDeweyForm = false;
      $scope.showGoogleForm = false;
      $scope.showDeweyRegisterForm = false;
    }

    $scope.register = function () {
      $.post('/sessions/register.json', {
        email: $scope.loginData.email,
        password: $scope.loginData.password,
        image_url: $scope.loginData.imageUrl,
        last_name: $scope.loginData.firstName,
        first_name: $scope.loginData.lastName
      }).done(function (response) {
        localStorageService.add('dewey_auth_token', response.auth_token);
        $scope.$apply(function() {
          $location.path('/search');
        });
      }).fail(function (response) {
        delete $window.sessionStorage.token;
        alert("Invalid Socialcast email and password - please retry.");
      });
    }
  }]);

  Dewey.DeweyApp.controller('LogoutController', ['$scope', '$injector', '$location', 'localStorageService', 'DeweyFactory', function ($scope, $injector, $location, localStorageService, DeweyFactory) {
    localStorageService.remove('dewey_auth_token');
    $location.path('/');
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

	return Dewey;

})(Dewey);

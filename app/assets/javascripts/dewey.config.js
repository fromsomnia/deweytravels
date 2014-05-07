var Dewey = (function (Dewey) {

  Dewey.DeweyApp.config(['$httpProvider', function ($httpProvider) {
    $httpProvider.interceptors.push('authInterceptor');
  }]);

  Dewey.DeweyApp.config(['$routeProvider',
                 function ($routeProvider) {
    // establish routes and resolve promises before displaying view
    $routeProvider
      .when('/', {
        controller: 'LoginController',
        templateUrl: '/login'
      })
      .when('/logout', {
        controller: 'LogoutController',
        templateUrl: '/logout'
      })
      .when('/search', {
        redirectTo: '/search/_',
      })
      .when('/search/:query', {
        controller: 'SearchController',
        templateUrl: '/search',
        resolve: {
          getSearchResults: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getSearchResults();
          }]
        }
      })
      .when('/users/:userId', {
        controller: 'UserController',
        templateUrl: '/user',
        resolve: {
          getUser: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getUser();
          }]
        }
      })
      .when('/users/:userId/edit', {
        controller: 'UserController',
        templateUrl: '/editUser',
        resolve: {
          getUser: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getUser();
          }]
        }
      })
      .when('/users/:userId/edit', {
        controller: 'UserController',
        templateUrl: '/editUser',
        resolve: {
          getUser: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getUser();
          }]
        }
      })
      .when('/topics/:topicId', {
        controller: 'TopicController',
        templateUrl: '/topic',
        resolve: {
          getTopic: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getTopic();
          }]
        }
      })
      .otherwise({
        redirectTo: '/'
      });

  }]);
  Dewey.DeweyApp.run(['$rootScope', 'currentUser', function($rootScope, currentUser) {
    currentUser.get(function(data) {
      if (data.uid)
        $rootScope.isLoggedIn = true; 
        $rootScope.currentUserId = data.uid;
      else {
        $rootScope.isLoggedIn = false;  
      }
    });
  }]);
	return Dewey;
	
})(Dewey);

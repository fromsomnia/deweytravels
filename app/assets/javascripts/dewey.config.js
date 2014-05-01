var Dewey = (function (Dewey) {

  Dewey.DeweyApp.config(['$httpProvider', function ($httpProvider) {
    $httpProvider.interceptors.push('authInterceptor');
  }]);

  Dewey.DeweyApp.config(['$routeProvider', function ($routeProvider) {
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
          }],
          getTopicsForUser: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getTopicsForUser();
          }],
          getAllTopics: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getAllTopics();
          }],
          getGraphNodesAndLinks: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getGraphNodesAndLinks();
          }],
          getTopicSuggestions: ['DeweyFactory', function(DeweyFactory) {
            return DeweyFactory.getTopicSuggestions();
          }],
        }
      })
      .when('/topics/:topicId', {
        controller: 'TopicController',
        templateUrl: '/topic',
        resolve: {
          getTopic: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getTopic();
          }],
          getUsersForTopic: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getUsersForTopic();
          }],
          getAllUsers: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getAllUsers();
          }],
          getGraphNodesAndLinks: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getGraphNodesAndLinks();
          }],
          getUserSuggestions: ['DeweyFactory', function(DeweyFactory) {
            return DeweyFactory.getUserSuggestions();
          }],
        }
      })
      .otherwise({
        redirectTo: '/'
      });

  }]);

	return Dewey;
	
})(Dewey);

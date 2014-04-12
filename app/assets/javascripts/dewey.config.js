var Dewey = (function (Dewey) {

  Dewey.DeweyApp.config(['$routeProvider', function ($routeProvider) {

    // establish routes and resolve promises before displaying view
    $routeProvider
      .when('/', {
        controller: 'LoginController',
        templateUrl: '/login'
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
          getNodesAndLinks: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getNodesAndLinks();
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
          getNodesAndLinks: ['DeweyFactory', function (DeweyFactory) {
            return DeweyFactory.getNodesAndLinks();
          }],
        }
      })
      .otherwise({
        redirectTo: '/'
      });

  }]);

	return Dewey;
	
})(Dewey);

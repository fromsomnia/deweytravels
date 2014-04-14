var Dewey = (function (Dewey) {

  // factory as our model; calls the API for data
  Dewey.DeweyApp.factory('DeweyFactory', ['$http', '$q', '$route', function ($http, $q, $route) {

    function prepareSearchResultData (results) {
      return _.map(results, function (result) {
        if (result.first_name && result.last_name) {
          result.category = 'users';
          result.name = result.first_name + ' ' + result.last_name;
          result.description = result.department || 'employee';
        } else {
          result.category = 'topics';
          result.name = result.title;
          result.description = 'topic';
        }
        if (!result.image)
          result.image = 'picture_placeholder.png';
        return result;
      });
    }

    function prepareUsersData (users) {
      return _.map(users, function (user) {
        user.name = user.first_name + ' ' + user.last_name;
        user.description = user.department || 'employee';
        user.category = 'users';
        return user;
      });
    }

    function getSearchResults () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/graphs/search.json?query=' + params.query)
        .success(function (response) {
          factory.searchResults = prepareSearchResultData(response);
          defer.resolve();
        });
      return defer.promise;
    }

    function getUser () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/users/' + params.userId + '.json')
        .success(function (response) {
          factory.user = response;
          defer.resolve();
        });
      return defer.promise;
    }

    function getUsersForTopic () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/topics/' + params.topicId + '/users.json')
        .success(function (response) {
          factory.usersForTopic = prepareUsersData(response);
          defer.resolve();
        });
      return defer.promise;
    }

    function getTopic () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/topics/' + params.topicId + '.json')
        .success(function (response) {
          factory.topic = response;
          defer.resolve();
        });
      return defer.promise;
    }

    function getAllTopics () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/topics.json')
        .success(function (response) {
          factory.allTopics = response;
          defer.resolve();
        });
      return defer.promise;
    }

    function getAllUsers () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/users.json')
        .success(function (response) {
          factory.allUsers = response;
          defer.resolve();
        });
      return defer.promise;
    }

    function getTopicsForUser () {
      var defer = $q.defer(),
        params = $route.current.params;
      $http.get('/users/' + params.userId + '/topics.json')
        .success(function (response) {
          factory.topicsForUser = response;
          defer.resolve();
        });
      return defer.promise;
    }

    function getGraphNodesAndLinks () {
      var defer = $q.defer(),
        params = $route.current.params,
        type = (params.topicId) ? 'topics' : 'users',
        id = params.topicId || params.userId;
      $http.get('/' + type + '/' + id + '/most_connected.json')
        .success(function (response) {
          factory.graphNodes = response.nodes;
          factory.graphLinks = response.links;
          defer.resolve();
        });
      return defer.promise;
    }

    // return public factory methods
    var factory = {};
    factory.getAllTopics = getAllTopics;
    factory.getAllUsers = getAllUsers;
    factory.getSearchResults = getSearchResults;
    factory.getUser = getUser;
    factory.getUsersForTopic = getUsersForTopic;
    factory.getTopic = getTopic;
    factory.getTopicsForUser = getTopicsForUser;
    factory.getGraphNodesAndLinks = getGraphNodesAndLinks;
    return factory;

  }]);

	return Dewey;

})(Dewey);
var Dewey = (function (Dewey) {

	// directive for graph visualization
  Dewey.DeweyApp.directive('dwyGraph', function () {
    return {
      restrict: 'E',
      link: function ($scope, element, attrs) {
        attrs.$observe('data', function (value) {
          if (value) {
            DeweyGraph('dwy-graph', JSON.parse(value));
          }
        });
      }
    };
  });

	return Dewey;

})(Dewey);

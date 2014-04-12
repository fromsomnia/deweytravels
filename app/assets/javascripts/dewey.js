// constructor for DeweyApp within namespace Dewey
var Dewey = (function (Dewey) {

  // ngRoute is for routing; ui.bootstrap is for Angular UI Bootstrap components
  Dewey.DeweyApp = angular.module('DeweyApp', ['ngRoute', 'ui.bootstrap']);

  return Dewey;

})(Dewey || {});

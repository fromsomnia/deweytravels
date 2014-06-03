var Dewey = (function (Dewey) {

  // ngRoute is for routing; ui.bootstrap is for Angular UI Bootstrap components
  Dewey.DeweyApp = angular.module('DeweyApp', ['ngRoute', 'ngOnboarding', 'ui.bootstrap', 'LocalStorageModule', 'angulartics', 'angulartics.mixpanel']);

  return Dewey;
})(Dewey || {});

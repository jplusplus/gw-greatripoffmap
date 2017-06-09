###*
 # @ngdoc function
 # @name gwAnonShellApp.controller:HomeCtrl
 # @description
 # # HomeCtrl
 # Controller of the gwAnonShellApp
###
angular.module('gwAnonShellApp').controller 'HomeCtrl', ($scope, places, cases, PlaceAggregation)->
  $scope.places = places.length
  $scope.cases  = cases.data.length

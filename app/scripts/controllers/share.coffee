###*
 # @ngdoc function
 # @name gwAnonShellApp.controller:ShareCtrl
 # @description
 # # ShareCtrl
 # Controller of the gwAnonShellApp
###
angular.module('gwAnonShellApp').controller 'ShareCtrl', ['$scope', '$modalInstance', 'constant.settings', ($scope, $modalInstance, settings)->
  $scope.link = settings.url
  $scope.width = 880
  $scope.height = 690
  $scope.close = $modalInstance.close
]

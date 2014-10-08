###*
 # @ngdoc function
 # @name gwAnonShellApp.controller:StudiesCtrl
 # @description
 # # StudiesCtrl
 # Controller of the gwAnonShellApp
###
angular.module('gwAnonShellApp').controller 'FeaturedStoriesCtrl', ($scope, cases)->
  # Get featured cases
  $scope.featuredCases = _.filter cases.data, feature: yes
  # Get case that are not featured
  # Only cases with a video
  $scope.recentCases = _.filter cases.data, (rc)-> !rc.feature and rc.new
  # Desc sort by desc id
  $scope.recentCases = _.sortBy $scope.recentCases, (rc)-> -1 * rc.id
  # Only the last 4 cases
  # $scope.recentCases = $scope.recentCases.slice(0, 4)


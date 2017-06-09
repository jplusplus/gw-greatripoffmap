###*
 # @ngdoc service
 # @name gwAnonShellApp.Cases
 # @description
 # # Cases
 # Service in the gwAnonShellApp.
###
angular.module('gwAnonShellApp').factory 'Cases', ['$http', '$rootScope', ($http, $rootScope)->
  # Simply gets the cases prefetch
  $http.get("./json/data.cases.json").success (cases)->
    $rootScope.$broadcast "cases:loaded", cases
]


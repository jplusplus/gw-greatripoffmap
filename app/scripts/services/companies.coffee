###*
 # @ngdoc service
 # @name gwAnonShellApp.Companies
 # @description
 # # Companies
 # Service in the gwAnonShellApp.
###
angular.module('gwAnonShellApp').factory 'Companies', ["$http", "$rootScope", ($http, $rootScope)->
  # Simply gets the companies prefetch
  $http.get("./json/data.companies.json").success (companies)->
    $rootScope.$broadcast "companies:loaded", companies
]

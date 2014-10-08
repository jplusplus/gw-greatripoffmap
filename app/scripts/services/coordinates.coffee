###*
 # @ngdoc service
 # @name gwAnonShellApp.Coordinates
 # @description
 # # Coordinates
 # Service in the gwAnonShellApp.
###
angular.module('gwAnonShellApp').factory 'Coordinates', ["$q", "$http", ($q, $http)->
  $q.all([
    $http.get("./json/canada.coordinates.json"),
    $http.get("./json/usa.coordinates.json"),
    $http.get("./json/countries.coordinates.json")
  ]).then (coordinates)->
    result = []
    for c in coordinates
      result = result.concat c.data
    result
]

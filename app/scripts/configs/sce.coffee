angular.module('gwAnonShellApp').config ['$sceDelegateProvider', ($sceDelegateProvider)->
  $sceDelegateProvider.resourceUrlWhitelist ['self']
]

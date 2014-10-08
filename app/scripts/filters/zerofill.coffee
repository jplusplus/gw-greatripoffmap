###*
 # @ngdoc filter
 # @name gwAnonShellApp.filter:zerofill
 # @function
 # @description
 # # zerofill
 # Filter in the gwAnonShellApp.
###
angular.module('gwAnonShellApp').filter 'zerofill', ->
  (n, length) ->
    "000000000000000000000000000000000#{n}".slice(-Math.max("#{n}".length, length))

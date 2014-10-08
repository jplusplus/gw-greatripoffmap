###*
 # @ngdoc filter
 # @name gwAnonShellApp.filter:stripTags
 # @function
 # @description
 # # stripTags
 # Filter in the gwAnonShellApp.
###
angular.module('gwAnonShellApp').filter 'stripTags', ->
  (text)-> String(text).replace(/<[^>]+>/gm, '')


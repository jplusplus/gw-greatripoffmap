###*
 # @ngdoc filter
 # @name gwAnonShellApp.filter:n
 # @function
 # @description
 # # n
 # Filter in the gwAnonShellApp. This is a dump implementation of
 # inflection through a filter.
###
angular.module('gwAnonShellApp').filter 'n', (inflector)->
  (word, number) ->
    if number > 1
      inflector.pluralize(word)
    else
      word

###*
 # @ngdoc filter
 # @name gwAnonShellApp.filter:wrapletters
 # @function
 # @description
 # # wrapletters
 # Filter in the gwAnonShellApp.
###
angular.module('gwAnonShellApp').filter 'wrapletters', ->
  (input, klass="")->
    letters = input.split("")
    text    = letters.join("</span><span class='#{klass}'>")
    output  = "<span class='#{klass}'>#{text}</span>"

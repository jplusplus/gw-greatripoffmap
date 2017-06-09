###*
 # @ngdoc filter
 # @name gwAnonShellApp.filter:addTargetBlank
 # @function
 # @description
 # # addTargetBlank
 # Filter in the gwAnonShellApp.
###
angular.module("gwAnonShellApp").filter "addTargetBlank", ->
  (x)->
    # defensively wrap in a div to avoid 'invalid html' exception
    tree = angular.element("<div>" + x + "</div>")
    # manipulate the parse tree
    tree.find("a").attr "target", "_blank"
    # trick to have a string representation
    angular.element("<div>").append(tree).html()

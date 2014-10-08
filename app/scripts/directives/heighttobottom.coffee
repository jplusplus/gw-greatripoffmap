###*
 # @ngdoc directive
 # @name gwAnonShellApp.directive:heightToBottom
 # @description
 # # heightToBottom
###
angular.module('gwAnonShellApp').directive 'heightToBottom', ["$window", ($window)->
  restrict: 'A'
  link: (scope, element, attrs) ->
    ev = "resize.heightToBottom"
    resize = ->
      element.css "height", $window.innerHeight - element.offset().top
      element.css("min-height", 1*attrs.heightToBottom) unless isNaN(attrs.heightToBottom)
    do resize
    angular.element($window).on ev, resize
    # Unbind existing scroll handler when destroying the directive
    scope.$on '$destroy', ->
      angular.element($window).off(ev)
]

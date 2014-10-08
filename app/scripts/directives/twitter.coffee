'use strict'

###*
 # @ngdoc directive
 # @name gwAnonShellApp.directive:twitter
 # @description
 # @src https://gist.github.com/Shoen/6350967
 # # twitter
###
angular.module('gwAnonShellApp').directive "twitter", ($timeout)->
  replace: yes
  template: '<span></span>'
  link: (scope, element, attr) ->
    $timeout ->
      url = attr.url or document.URL
      twttr.widgets.createShareButton url, element[0],
        count: "none"
        text: attr.text
        via: attr.via

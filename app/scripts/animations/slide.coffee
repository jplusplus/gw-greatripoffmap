angular.module('gwAnonShellApp').animation ".animation-slide", ()->
    beforeAddClass: (element, className, done)->
        if className is "ng-hide"
            jQuery(element).show().slideUp(200, done)
        return null

    removeClass: (element, className, done)->
        if className is "ng-hide"
            jQuery(element).hide().slideDown(200, done)
        return null

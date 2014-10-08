###*
 # @ngdoc filter
 # @name gwAnonShellApp.filter:youtubeThumbnail
 # @function
 # @description
 # # youtubeThumbnail
 # Filter in the gwAnonShellApp.
###
angular.module('gwAnonShellApp').filter 'youtubeThumbnail', ->
  (url, size=0) ->
    getId = (url)->
      video_id = url.split("v=")[1]
      ampersandPosition = video_id.indexOf("&")
      unless ampersandPosition is -1
        video_id.substring(0, ampersandPosition)
      else
        video_id
    "http://img.youtube.com/vi/#{getId(url)}/#{size}.jpg"

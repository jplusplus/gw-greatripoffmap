###*
 # @ngdoc directive
 # @name gwAnonShellApp.directive:map
 # @description
 # # map
###
angular.module('gwAnonShellApp').directive('map', ["leafletData", "$state", (leafletData, $state)->
  templateUrl: 'views/map.html'
  restrict: 'E'
  link: (scope, element, attrs)->
    # Disable or enable a list of interactions
    interactions = (map)->
      methods = ["dragging", "touchZoom", "keyboard"]
      disable: ->
        do map[method].disable for method in methods
      enable: ->
        do map[method].enable for method in methods

    # Update zoom according the current state
    mapState = ()->
      leafletData.getMap("main-map").then (map)->
        switch $state.current.name
          when "explore"
            map.setView L.latLng(30.71109,0.7191036), 2
            do interactions(map).enable
          when "explore.place"
            do interactions(map).disable
        # Disbale doubleclick everywhere
        map.doubleClickZoom.disable()
    # Watch the state change
    scope.$on "$stateChangeSuccess", mapState
    do mapState
    # Default map configuration
    angular.extend scope,
      # Map boundaries
      maxbounds:
        southWest: L.latLng(70, 180)
        northEast: L.latLng(-50, -180)
      center:
        zoom: 2
        lat:30.71109
        lng:0.7191036
      defaults:
        scrollWheelZoom: no
        zoomControlPosition: 'topright'
      tiles:
        #url: "http://openmapsurfer.uni-hd.de/tiles/roadsg/x={x}&y={y}&z={z}"
        url: "./images/blank.gif"
        options:
          opacity: 0
          detectRetina: no
          reuseTiles: yes
])

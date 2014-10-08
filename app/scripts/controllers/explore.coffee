###*
 # @ngdoc function
 # @name gwAnonShellApp.controller:ExploreCtrl
 # @description
 # # ExploreCtrl
 # Controller of the gwAnonShellApp
###
class ExploreCtrl
  @$inject: [
    "$scope",
    "constant.settings",
    "constant.crimetypes",
    "$state",
    "$http",
    "$q",
    "$location",
    "$document",
    "leafletData",
    "Restangular",
    "Tree",
    "Crimetypes",
    "Companies",
    "Coordinates",
    "PlaceAggregation",
    "places"
  ]

  constructor:(@scope, @settings, @crimetypes, @state, @http, @q, @location, @document, @leafletData, @Restangular, @Tree, @Crimetypes, @Companies, @Coordinates, @PlaceAggregation, @places)->
    # Create a unique token for this controller instance.
    # We further use this token to create unique key in order
    # to manipulates dataset once by instance.
    @controllerToken = _.uniqueId("map:") + ":"
    # Scroll to the sub-view
    @document.scrollToElement angular.element(".header"), 0, 300
    # ────────────────
    # Scope attributes
    # ────────────────
    # Bind scope's methods
    @scope.filterClasses = @filterClasses
    @scope.getPlace      = @getPlace
    @scope.selectPlace   = @selectPlace
    @scope.focusOn       = @focusOn
    @scope.allowFocus    = @allowFocus
    @scope.crimetypes    = @crimetypes.name
    @scope.filterBy = (type=null)=>
      # Ensure the view is reseted
      do @resetLocation
      @location.search "type", type
    @scope.switchTo = (view=null)=>
      # Ensure the view is reseted
      do @resetLocation
      @location.search "view", view
    # Count shortcup
    @scope.count = @count
    # Defaults values
    @scope.activeType        = null
    @scope.activeJuridiction = null
    @scope.activeWith        = null
    @scope.activeView        = 'companies'
    @scope.mapLoading        = yes
    # ──────────────
    # Scope Watchers
    # ──────────────
    @scope.$on "leafletDirectiveMap.click", => @selectPlace(null)
      # Extract the code from the feature's properties
    @scope.$on "map.feature:click",(e, f)=> @selectPlace f.id or f.properties.code
    @scope.$on "map.feature:dblclick",(e, f)=> @quickSelectPlace f.id or f.properties.code
    # Click on a circle or a feature, draw its link
    @scope.$on "map.circle:click", (ev, place)=> @selectPlace place.code
    @scope.$on "map.circle:dblclick", (ev, place)=> @quickSelectPlace place.code
    # Mouseover on a circle, draw its link
    @scope.$on "map.circle:mouseover", (ev, place)=>
      place = @getPlace place.code, @filteredValues
      # Can change the selected country outsite the "explore" state
      if @state.is("explore") and !@scope.activeJuridiction?
        method = if @scope.activeView is "companies" then 'drawCompaniesLinks' else 'drawVictimsLinks'
        @[method] place, @scope.activeJuridiction isnt place.code
      # Display a popup on the circle
      @popupOnPlace place
    # Mouse leaving a cicle
    # Rerender the map
    @scope.$on "map.circle:mouseout", =>
      @map.closePopup()
      @renderMap(no)
    # Update filtered values when value are loaded
    @scope.$on "values:loaded", @updateFilteredValues
    # User change filter
    @scope.$watch "activeType + activeJuridiction + activeWith", @updateFilteredValues, yes
    # Location changes
    @scope.$watch (=>@location.search()), @readLocationSearch, yes
    # State change
    @scope.$on "$stateChangeSuccess", @readStateParams, yes
    do @readStateParams
    # ────────────────
    # Class attriubtes
    # ────────────────
    # Map objects
    @polylines = []
    @circles = []
    # Full dataset
    @values = []
    # Filtered dataset
    @filteredValues = @values
    # Place were we do not count or create feature
    @excludePlaces = @settings.excludePlaces
    # The same for filtered values
    @cachedFilteredValues = {}
    # ─────────────────
    # Resolves promises
    # ─────────────────
    # Load services together
    @q.all([
      # USA' states to display on the map
      @http.get("json/usa.geo.json"),
      # Canada province to display on the map
      @http.get("json/canada.geo.json"),
      # World countries geojson to display on the map
      @http.get("json/countries.geo.json")
      # Coordinates of areas
      @Coordinates,
      # Data tree
      @Tree,
      # Wait for the map to be created
      @leafletData.getMap("main-map")
    # Then starts!
    ]).then (services)=>
      # Map
      @map = services[5]
      # Set geojson on the map
      @usaFeatures = @setFeatures services[0].data
      @canFeatures = @setFeatures services[1].data
      # Remove some places
      _.remove(services[2].data.features, id: code) for code in @excludePlaces
      # Set the filterd features of the countries to the map
      @wldFeatures = @setFeatures services[2].data
      # Coordonates list
      @coordinates = services[3]
      # Companies list
      @values = services[4]
      # Broadcast change
      @scope.$broadcast "values:loaded", @values
      # Now we can display the map
      @scope.mapLoading = no

  setFeatures: (features)=>
    # We use a default style for the features
    geojson = L.geoJson features,
      className: "explore__map__feature"
      onEachFeature: (feature, layer)=>
        # Save the feature code for this layer
        layer.code = feature.id or feature.properties.code
        for e in ["click", "mouseover", "mouseout", "dblclick"]
          # Bind a function to the click
          layer.on e, (ev)=>
            @scope.$apply =>
              # Broadcast click as an event from the leaflet directive
              @scope.$broadcast("map.feature:#{ev.type}", feature, ev)
    # Add the layer to the map without using the directive shortcut
    # (that doesn't allow multiple geojson)
    geojson.addTo(@map).bringToBack()
    # Return the new geojson
    geojson

  setFeatureClasses: =>
    # Set the given class to the layer
    setClass = (layer, clss)=>
      # This might be composed of several layers
      paths = _.pluck layer._layers, "_path"
      # Add the current path
      paths.push(layer._path) if layer._path?
      # For each path, change the class attribute
      $(path).attr "class", "explore__map__feature #{clss}" for path in paths
    # Reset classes:
    # Find any active feature
    $(@map._container).find(".explore__map__feature")
      # And restore its class
      .attr("class", "explore__map__feature")
    # We migth have an active element
    if @scope.activeJuridiction?
      # Fetch every map layer
      _.each @map._layers, (layer)=>
        # The current layer has a code
        if layer.code?
          # It's the active layer (if any)
          if layer.code is @scope.activeJuridiction
            setClass(layer, "explore__map__feature--active")
          # It's the active-with layer (if any)
          else if layer.code is @scope.activeWith
            setClass(layer, "explore__map__feature--active-with")
          # It could be activated
          else if @hasRelationship layer.code
            setClass(layer, "explore__map__feature--could-activate")

  filterClasses: (filter)=>
    "explore__header__filters__item--active" if @scope.activeType is filter

  getPlace: (code=@scope.activeJuridiction, companies=@filteredValues)=>
    # Search the place among companies
    place = @PlaceAggregation.getPlace code, companies
    # Does the place exist?
    if place?
      # Find coordinates for the given place
      _.extend place, @codeToCordinates(place.code)


  count: (set)=>
    switch set
      when "companies" then do @getCompaniesCount
      when "victims" then do @getVictimsCount

  getCompaniesCount: =>
    place = @getPlace()
    return 0 unless place?
    # Dataset change according the view
    set = if @scope.activeView is "victims" then "victims_companies" else "companies"
    place[set] = [] unless place[set]?
    # Not second active country
    unless @scope.activeWith?
      place[set].length
    else
      companies = _.filter place[set], (company)=>
        if set is "victims_companies"
          company.incorporations.indexOf(@scope.activeWith) > -1
        else
          !! _.find company.involvement_in_cases, (c)=>
            !! _.find c.victims, code: @scope.activeWith
      companies.length

  getVictimsCount: =>
    place = @getPlace()
    return 0 unless place?
    # Dataset change according the view
    set = if @scope.activeView is "victims" then "victims_places" else "victims"
    place[set] = [] unless place[set]?
    place[set].length

  # Do the first juridiction has victims from the second?
  hasVictimsIn: (j1, j2)=> @PlaceAggregation.hasVictimsIn(j1, j2, @filteredValues)
  # Do the first juridiction has companies from the second?
  hasCompaniesIn: (j1, j2)=>  @PlaceAggregation.hasCompaniesIn(j1, j2, @filteredValues)
  # Convert code to coordinates
  codeToCordinates: (code)=> _.find @coordinates or [], code: code
  # Remove every single one
  removeCircles: => _.each @circles, (layer)=> @map.removeLayer(layer)
  # Remove every single one
  removePolylines: => _.each @polylines, (layer)=> @map.removeLayer(layer)

  drawCompanies: (companies=@filteredValues, animate=no)=>
    companiesByPlace = @PlaceAggregation.countByPlace companies
    # Calculate the maximun count
    max = _.max(companiesByPlace, (p)->p.companies.length)
    if max.companies?
      # Place may gave companies
      for place in _.filter(companiesByPlace, (c)-> c.companies.length)
        # Find coordinates for the given place
        coordinates = @codeToCordinates place.code
        # We find coordinates for this country
        if coordinates?
          classNames = ["explore__map__circle"]
          # Add an active class to the current country
          classNames.push "explore__map__circle--active" if place.code is @scope.activeJuridiction
          # Radius of the circle
          radius = 5 + place.companies.length/max.companies.length*30
          # Draw a circle marker
          circle = L.circleMarker( [coordinates.lat, coordinates.lng],
            radius: radius
            className: classNames.join(" ")
          )
          # Add it to the map
          @addCircle circle, place, @map, animate
    # Return companies list by place
    companiesByPlace

  drawCompaniesLinks: (place, animate=no)=>
    return unless @scope.activeView is "companies"
    # Every link starts somewhere
    return unless place?
    # For each victim's juridiction
    for juridiction in (place.victims or [])
      # Existing coordinates
      continue unless juridiction.lat?
      # Create polylines
      @createPolyline place.code, juridiction.code, juridiction.code, animate
      # Create class array
      classNames = ["explore__map__extremity"]
      # Add an active class to the current country
      classNames.push "explore__map__extremity--active" if juridiction.code is @scope.activeWith
      # Create an extremity circle
      circle = L.circleMarker [juridiction.lat, juridiction.lng],
        radius: 3
        className: classNames.join " "
      # Add it to the map
      @addCircle circle, juridiction, @map, animate

  drawVictims: (companies=@filteredValues, animate=no)=>
    victimsByPlace = @PlaceAggregation.countByPlace companies
    # List places where there is victims
    for juridiction in _.filter(victimsByPlace, (p)-> p.victims_cases.length)
      # Find coordinates for the given place
      coordinates = @codeToCordinates juridiction.code
      # We find coordinates for this country
      if coordinates?
        classNames = ["explore__map__extremity"]
        # Add an active class to the current country
        classNames.push "explore__map__extremity--active" if juridiction.code is @scope.activeJuridiction
        # Draw a circle marker
        circle = L.circleMarker [coordinates.lat, coordinates.lng],
          radius: 4
          className: classNames.join " "
        # Add it to the map
        @addCircle circle, juridiction, @map, animate
        circle.bringToFront()
    # Return companies list by place
    victimsByPlace

  drawVictimsLinks: (place, animate=no)=>
    return unless @scope.activeView is "victims"
    # Every link starts somewhere
    return unless place?
    # Get all places data
    victimsByPlace = @PlaceAggregation.countByPlace @filteredValues
    # Calculate the maximun count
    max = _.max(victimsByPlace, (p)->p.victims_places.length)
    maxCount = max.victims_places.length
    # Place may gave companies
    for victims_place in (place.victims_places or [])
      # Get the place and coordinates for the given ending code
      _.extend victims_place, @getPlace(victims_place.code)
      # Existing coordinates
      continue unless victims_place.lat?
      # Create the polyline between points
      @createPolyline(victims_place.code, place.code, victims_place.code, animate)
      # Create class array
      classNames = ["explore__map__circle"]
      # Add an active class to the current country
      classNames.push "explore__map__circle--active" if victims_place.code is @scope.activeWith
      # Draw a circle marker to the end of the line
      circle = L.circleMarker [victims_place.lat, victims_place.lng],
        radius: 5 + victims_place.victims_places.length/maxCount*30
        className: classNames.join " "
      # Add it to the map
      @addCircle circle, victims_place, @map, animate


  createPolyline: (srcCode, destCode, activeCode, animate=no)=>
    # Get coordinates
    src = @codeToCordinates(srcCode)
    dest = @codeToCordinates(destCode)
    # Stop now if not found
    return unless src? and dest?
    # Create the polyline bound
    bounds = [
      L.latLng(src.lat, src.lng),
      L.latLng(dest.lat, dest.lng)
    ]

    classNames = ["explore__map__link"]
    # Add an active class to the current country
    classNames.push "explore__map__link--active" if activeCode is @scope.activeWith
    # Draw the polyline
    polyline = new L.Polyline bounds,
      className: classNames.join " "
      weight: 2
      # for L.ArcedPolyline
      # distanceToHeight: new L.LinearFunction([0, 0], [0, 0])

    # Save the polylines
    @polylines.push polyline
    # Fill the map
    @map.addLayer(polyline)
    # Should we animate the new path ?
    if animate
      path = d3.select(polyline._path)
      totalLength = path.node().getTotalLength();
      path.attr("stroke-dasharray", totalLength + " " + totalLength)
          .attr("stroke-dashoffset", totalLength)
          .style("stroke-opacity", 0)
          .transition()
            .duration(300)
            .ease("linear")
            .attr("stroke-dashoffset", 0)
            .style("stroke-opacity", 1)
    # Returns the polyline
    polyline


  addCircle: (circle, place, map, animate=no)=>
    idx = @circles.push(circle) - 1
    circle.addTo map
    # Bind multiple events to the scope
    _.each ["mouseover", "mouseout", "click", "dblclick"], (ev)=>
      # Propagate the events
      circle.on ev, ( (place, e)=>
        (e)=>
          @scope.$apply =>
            @scope.$broadcast("map.circle:" + ev, place, e)
      )(place, ev)
    # Should we animate the circle?
    if animate
      g        = d3.select(circle._path)
      el       = g.node()
      try
        # It might failed if the element is not appended yet
        # ("NS_ERROR_FAILURE" exception)
        bbox = el.getBBox()
      catch e
        # Stop here before hidding it
        return idx
      [cx, cy] = [bbox.x + bbox.width/2, bbox.y + bbox.height/2]
      matrix = (scale)->
        sx = sy = scale
        "matrix(#{sx}, 0, 0, #{sy}, #{cx-sx*cx}, #{cy-sy*cy})"
      g.attr("transform", matrix(0))
        .transition()
          .duration(600)
          .ease("linear")
          .attrTween("transform", (d,i,a)->matrix)
    idx


  updateFilteredValues: ()=>
    # Stop until the map is ready
    return unless @map?
    # We can use a cached version of the filtered values
    key = "type-#{@scope.activeType}"
    if @cachedFilteredValues[key]?
      # Works on cloned object
      @filteredValues = @cachedFilteredValues[key]
    else
      @filteredValues = _.cloneDeep @values
      # Create an identifier for this dataset
      # so we can later retreive calculation related to it.
      @filteredValues.hash = _.uniqueId(@controllerToken)
      # Filter by type
      if @scope.activeType?
        # Remove other type
        _.remove @filteredValues, (company)=>
          # Not cases, not visible
          return yes if company.involvement_in_cases.length is 0
          # Does this company have this type?
          return !!_.find company.involvement_in_cases, (c)=>
            @Crimetypes.getMultiple(c.crimetype).indexOf(@scope.activeType) is -1
      @cachedFilteredValues[key] = @filteredValues
    # Bind values to the scope for mobile view
    @scope.juridictions = @PlaceAggregation.countByPlace @filteredValues
    # Render the map again
    @renderMap !@scope.activeJuridiction and !@scope.activeWith

  renderMap: (animate=no)=>
    do @removeCircles
    do @removePolylines
    # Some features of the map may have a special class
    do @setFeatureClasses
    # Draw first level visualisation according active view
    switch @scope.activeView
      when "victims"
        # Draw juridiction where gulty companies are based
        @drawVictimsLinks @getPlace(), animate if @scope.activeJuridiction?
        # Draw juridictions with victims
        @drawVictims @filteredValues, animate
      else
        # Draw juridiction victims links
        @drawCompaniesLinks @getPlace(), animate if @scope.activeJuridiction?
        # Draw juridictions with companies count
        @drawCompanies @filteredValues, animate

  # Used for double click selection
  quickSelectPlace: (code)=>
    if code isnt @scope.activeJuridiction and @hasRelationship(code)
      @state.go "explore.place", code: @scope.activeJuridiction, with: code
    else
      @state.go "explore.place", code: code

  hasRelationship: (code)=>
    # Companies view, must have victims
    ( @scope.activeView is 'companies' and
    @hasVictimsIn @scope.activeJuridiction, code ) or
    # Victims view, must have companies
    ( @scope.activeView is 'victims' and
    @hasCompaniesIn @scope.activeJuridiction, code )

  selectPlace: (code, force=no)=>
    # Can change the selected country outsite the "explore" state
    if @state.is("explore")
      if code is null or not @getPlace(code)?
        @location.search "juridiction", null
        @location.search "with", null
      # Select a new place
      else if @scope.activeJuridiction is null or force
        # Some place must not be clickable
        return unless code is null or @allowFocus code
        @location.search "juridiction", code
        @location.search "with", null
      else
        @selectSecondPlace code
    # Go back to the explore state
    else
      #@scope.activeWith = @scope.activeJuridiction = null
      @state.go "explore", {juridiction: null, with: null}, reload: yes


  selectSecondPlace: (code)=>
    if @hasRelationship code
      @location.search "with", code
    else
      @selectPlace code, yes

  popupOnPlace: (place)=>
    return console.warn(error: "A place has not coordinates", place: place) unless place.lat?
    # Set the center of the popup on the place
    latlng = new L.latLng place.lat, place.lng
    # Create the popup into an attribute
    # to have only one popup at a time
    @popup = L.popup().setLatLng(latlng).setContent(place.name).openOn @map

  focusOn: (code)=>
    if code?
      @scope.placeFocus = null
      @state.go("explore.place", code: code)

  allowFocus: (country)=>
    place = @getPlace(country.code ? country)
    indicator = if @scope.activeView is "companies" then "companies" else "victims_cases"
    # Indicator must have values
    place? and !! place[indicator].length

  resetLocation: =>
    for param in ["type", "juridiction", "with"]
      @location.search param, null

  readLocationSearch: (search)=>
    # Change active filter according the location's search
    @scope.activeType = @location.search().type or null
    # Change the active juridiction
    @scope.activeJuridiction = @location.search().juridiction ? null
    # We may want to see the relationships with a juridiction
    @scope.activeWith = @location.search().with ? null
    # Always override location parameters with states parametes
    # to preserve ui-router consistency
    do @readStateParams
    # Hide how to when a juridiction is activated
    @scope.hideHowTo = yes if @scope.activeJuridiction isnt null

  readStateParams: ()=>
    # Active country code given
    if @state.params.code?
      @scope.activeJuridiction = @state.params.code
    # Change view type (default on companies)
    @scope.activeView =  @state.params.view ? 'companies'


angular.module('gwAnonShellApp').controller 'ExploreCtrl', ExploreCtrl

###*
 # @ngdoc function
 # @name gwAnonShellApp.controller:ExplorePlaceCtrl
 # @description
 # # ExplorePlaceCtrl
 # Controller of the gwAnonShellApp
###
class ExplorePlaceCtrl
  @$inject: [
    "$scope",
    "$stateParams",
    "$document",
    "$timeout",
    "place",
    "companies",
    "leafletData",
    "Crimetypes",
    "PlaceAggregation",
    "Utils"
  ]
  constructor: (@scope, @stateParams, @document, @timeout, @place, @companies, @leafletData, @Crimetypes, @PlaceAggregation, @Utils)->
    # Wait a small delay before srolling to avoid rendering issue
    @timeout =>
      # Scroll to the sub-view
      @document.scrollToElement angular.element(".explore__place"), 0, 300
    , 500
    # Scope the cases set
    switch @stateParams.view
      # Victims view
      when "victims"
        @scope.cases  = @place.victims_cases
        @scope.places = @place.victims_places
        # Restrict cases to one juridication
        if @stateParams.with?
          # Filter cases to show using the victims list
          @scope.cases = _.filter @scope.cases, (c)=>
            juridictions = @Utils.caseCompaniesJuridictions(c, @companies)
            # Has a victim in the given juridications
            !! _.find juridictions, code: @stateParams.with
      # Companies view (default)
      else
        @scope.cases   = @place.cases
        @scope.victims = @place.victims
        # Restrict cases to one juridication
        if @stateParams.with?
          # Filter cases to show using the victims list
          @scope.cases = _.filter @scope.cases, (c)=>
            # Has a victim in the given juridication
            !! _.find c.victims, isoa3: @stateParams.with
    if @stateParams.with?
      # Notices the scope that we have a juridiction to deal with
      @scope.with = @PlaceAggregation.getPlace @stateParams.with, @companies
      # Filter victims place too
      @place.victims = _.filter @place.victims, isoa3: @stateParams.with
    # Common scope attributes
    @scope.place      = @place
    @scope.crimetypes = @getCrimetypes @scope.cases
    # All cases related to this country (for mobile view)
    @scope.allCases   = _.uniq place.cases.concat(@place.victims_cases), "id"
    @scope.allCrimetypes = @getCrimetypes @scope.allCases
    # Add the juridictions of the companies involved in a given case.
    # First, for the case of the current view
    @scope.cases = _.map @scope.cases, (c)=>
      c.companies_juridictions = @Utils.caseCompaniesJuridictions(c, @companies)
      return c
    #  Then for everyc ase
    @scope.allCases = _.map @scope.allCases, (c)=>
      c.companies_juridictions = @Utils.caseCompaniesJuridictions(c, @companies)
      return c
    # Initialize map
    leafletData.getMap("main-map").then (map)=>
      # Zoom to the current place
      map.setView L.latLng(@place.lat, @place.lng), 4

  getCrimetypes: (cases)=>
    crimetypes = _.pluck cases, "crimetype"
    slugs = []
    # Map types values into the right slug
    angular.forEach crimetypes, (types)=>
      slugs = slugs.concat @Crimetypes.getMultiple(types)
    # Use slugs once
    _.uniq slugs



angular.module('gwAnonShellApp').controller 'ExplorePlaceCtrl', ExplorePlaceCtrl

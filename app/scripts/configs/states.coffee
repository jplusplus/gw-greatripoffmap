angular.module('gwAnonShellApp').config [
  '$stateProvider',
  '$urlRouterProvider',
  '$locationProvider',
  ($stateProvider, $urlRouterProvider, $locationProvider)->
    $locationProvider.hashPrefix('!')
    $urlRouterProvider.otherwise "/"

    $stateProvider.state "home",
      url: "/"
      templateUrl: "views/home.html"
      controller: 'HomeCtrl'
      resolve:
        places: ["PlaceAggregation", (PlaceAggregation)-> PlaceAggregation ]
        cases: ["Cases", (Cases)-> Cases ]

    $stateProvider.state "about",
      url: "/about"
      templateUrl: "views/about.html"

    $stateProvider.state "featured-stories",
      url: "/featured-stories"
      templateUrl: "views/featured-stories.html"
      controller: "FeaturedStoriesCtrl"
      resolve:
        cases: ["Cases", (Cases)-> Cases ]

    $stateProvider.state "feedback",
      url: "/feedback"
      templateUrl: "views/feedback.html"

    $stateProvider.state "contribute",
      url: "/contribute"
      templateUrl: "views/contribute.html"

    $stateProvider.state "case",
      url: "/case/:id"
      resolve:
        companies: ["Tree", (Tree)-> Tree ]
        currentCase: ["$stateParams", "$q", "Cases", ($stateParams, $q, Cases)->
          deferred = $q.defer()
          Cases.then (cases)->
            currentCase = _.find cases.data, id: 1*$stateParams.id
            if currentCase?
              deferred.resolve currentCase
            else
              deferred.reject "Case not found"
          deferred.promise
        ]
      views:
        "":
          templateUrl: "views/case.html"
          controller: 'CaseCtrl'
        "og":
          templateUrl: "views/case.og.html"
          controller: 'CaseCtrl'

    $stateProvider.state "explore",
      url: "/explore/:view"
      templateUrl: "views/explore.html"
      controller: 'ExploreCtrl'
      params:
        view:
          value: "companies"
      resolve:
        # Just resolve the promise
        places: ["PlaceAggregation", (PlaceAggregation)-> PlaceAggregation ]

    $stateProvider.state "explore.place",
      url: "/:code?with&type"
      templateUrl: "views/explore.place.html"
      controller: 'ExplorePlaceCtrl'
      resolve:
        companies: ["Tree", (Tree)-> Tree ]
        place: ['$stateParams', '$q', 'Crimetypes', 'PlaceAggregation', 'Coordinates', 'Tree', ($stateParams, $q, Crimetypes, PlaceAggregation, Coordinates, Tree)->
          deferred = $q.defer()
          # Loads Tree and Coordinates to merge them
          $q.all([
            Tree,
            Coordinates
          ]).then (values)->
            companies = values[0]
            # We may filter the companies by type
            if $stateParams.type?
              # Remove other type
              companies = _.reject companies, (company)=>
                # Not cases, not visible
                return yes if company.involvement_in_cases.length is 0
                # Does this company have this type?
                !!_.find company.involvement_in_cases, (c)=>
                  Crimetypes.getMultiple(c.crimetype).indexOf($stateParams.type) is -1
            # Create a unique ID
            companies.hash = do _.uniqueId
            # We get all data aggregated by this place
            # and with the filtered dataset
            aggregation = PlaceAggregation.getPlace($stateParams.code, companies)
            place = _.find values[1], code: $stateParams.code
            place = _.cloneDeep place
            if place? and aggregation?
              # Merge the to places
              place = angular.extend place, aggregation
              deferred.resolve place
            else
              deferred.reject "Place not found."
          deferred.promise
        ]
]


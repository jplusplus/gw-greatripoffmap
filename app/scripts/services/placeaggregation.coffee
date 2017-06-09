###*
 # @ngdoc service
 # @name gwAnonShellApp.PlaceAggregation
 # @description
 # # PlaceAggregation
 # Factory in the gwAnonShellApp.
###
angular.module('gwAnonShellApp').factory 'PlaceAggregation', ["Tree", "constant.settings", (Tree, settings)->
  # A cache of results of the countByPlace function.
  # Every object defines an used to cache its aggregation
  countByPlaceHashes = {}
  # A cache of results of the getPlace functions.
  # This will depend of the version of the companies object given
  placesHashes = {}
  # Do the first juridiction has victims from the second?
  hasVictimsIn = (j1, j2, companies)=>
    # Avoid comparing the same juridiction or null values
    return no if j1 is null or j2 is null or j1 is j2
    # Get the place
    p1 = getPlace(j1, companies)
    # We new data for the the current place
    return no unless p1?
    # Victims from p1 are p2
    return !! _.find p1.victims, isoa3: j2

  # Do the first juridiction has companies from the second?
  hasCompaniesIn = (j1, j2, companies)=>
    # Avoid comparing the same juridiction or null values
    return no if j1 is null or j2 is null or j1 is j2
    # Get the place
    p2 = getPlace(j2, companies)
    # We new data for the the current place
    return no unless p2?
    # Companies from p2 are p2
    return !! _.find p2.victims, isoa3: j1

  getPlace = (code, companies)->
    if code?
      # Create a subset of places for this companies list
      placesHashes[companies.hash] = {} unless placesHashes[companies.hash]
      # Does this place already exist in the subset?
      return placesHashes[companies.hash][code] if placesHashes[companies.hash][code]?
      # Search the place among companies
      companiesByPlace = countByPlace companies
      # Find the place
      place = _.find companiesByPlace, code: code
      # Cache and returns the created object
      placesHashes[companies.hash][code] = place

  getCompanyPlaces = (company)->
    codes = _.pluck(company.incorporated_in, "isoa3")
    codes = codes.concat _.pluck(company.usincorporated, "i_sous")
    codes = codes.concat _.pluck(company.caincorporated, "i_so")
    codes

  countByPlace = (companies)=>
    # Use cached version of this aggregation
    return countByPlaceHashes[companies.hash] if countByPlaceHashes[companies.hash]?

    createPlace = (code, name)->
      # ISO code of this juridiction
      code             : code
      # Name of this juridiction
      name             : name
      # Cases commit by companies based in this juridiction
      cases            : []
      # Companies based in this juridiction
      companies        : []
      # Countries were people are armed by this juridiction
      victims          : []
      # Juridictions where companies that commit crimes in this juridiction are based
      victims_places   : []
      # Cases that commit victims from this juridiction
      victims_cases    : []
      # Companies that commit crimes in this juridiction
      victims_companies: []

    record = (inc, key, company)->
      code = inc[key]
      # We may skip some place
      return {} unless settings.excludePlaces.indexOf(code) is -1
      # Create an object for this place
      unless places[code]?
        # This object count and record companies
        places[code] = createPlace code, inc.name
      company_cases  = company.involvement_in_cases or []
      company_victims_juridctions = []
      # For each case...
      _.each company_cases, (c)->
        # Save victim of this case
        _.each c.victims, (v)->
          # Exclude some victims locations
          if settings.excludePlaces.indexOf(v.code) is -1
            company_victims_juridctions.push v
      # Edit the object with the current company data
      places[code].count++
      places[code].victims = _.uniq places[code].victims.concat(company_victims_juridctions), "code"
      places[code].cases   = _.uniq places[code].cases.concat(company_cases), "id"
      places[code].companies.push company
      # Return the place
      places[code]

    # Create a hash for this companies list if needed
    hash = companies.hash or do _.uniqueId
    # This function always works with a copy of the data
    # to avoid conflicts during filtering
    companies = _.cloneDeep companies
    companies.hash = hash
    # List of places
    places = {}
    # List of cases
    cases  = []
    for company in companies
      record(inc, "isoa3",  company).zone = null for inc in company.incorporated_in
      record(inc, "i_sous", company).zone = "United States"   for inc in company.usincorporated
      record(inc, "i_so",   company).zone = "Canada"for inc in company.caincorporated
      # Save all cases
      cases = cases.concat (company.involvement_in_cases or [])
    # Extract every cases
    cases = _.uniq cases, "id"
    # Collect victim's places
    for code, place of places
      for victim in place.victims
        # The place did not have any companies in it
        unless places[victim.isoa3]?
          # This object count and record companies
          places[victim.isoa3] = createPlace victim.isoa3, victim.name
        # Cases that harms victim in this place
        places[victim.isoa3].victims_cases = _.filter cases, (c)->
          # Does this case have victim in the current place?
          !!_.find c.victims, isoa3: victim.isoa3
        # Juridictions where companies that commit crimes are based
        for victims_case in places[victim.isoa3].victims_cases
          for company in victims_case.companyinvolvement
            # Save the company
            places[victim.isoa3].victims_companies.push company
            # Extract juridiction from a company
            company_places_codes = getCompanyPlaces company
            company_places = _.map company_places_codes, (code)-> places[code]
            # Merge victims lists
            places[victim.isoa3].victims_places = places[victim.isoa3].victims_places.concat company_places
        # Remove missing victim's place
        places[victim.isoa3].victims_places = _.filter places[victim.isoa3].victims_places, (p)-> p?
        # Unique victims!
        places[victim.isoa3].victims_places = _.uniq places[victim.isoa3].victims_places, "code"
        places[victim.isoa3].victims_places = _.filter places[victim.isoa3].victims_places, (j)->
          # Exclude some places
          settings.excludePlaces.indexOf(j.isoa3) is -1
        # Unique companies too!
        places[victim.isoa3].victims_companies = _.uniq places[victim.isoa3].victims_companies, "id"
    # Order places by count (DESC).
    # The sorting function will create an array
    # (instead of an object).
    result = _(places).sortBy((p)->p.companies.length).reverse().value()
    # Create a uniq id into this object to retreive it's cached version
    if companies.hash?
      # Save the and returns result
      countByPlaceHashes[companies.hash] = result
    result

  # Create a promise throught the Tree service
  tree = Tree.then countByPlace
  # Extent the promise with custom method and return it
  angular.extend tree,
    countByPlace  : countByPlace
    getPlace      : getPlace
    hasCompaniesIn: hasCompaniesIn
    hasVictimsIn  : hasVictimsIn
]

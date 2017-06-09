###*
 # @ngdoc service
 # @name gwAnonShellApp.Tree
 # @description
 # # Tree
 # This factory merge companies list with cases to creates a tree of data
###
angular.module('gwAnonShellApp').factory 'Tree', ["$q", "Cases", "Companies", "Coordinates", "constant.settings", ($q, Cases, Companies, Coordinates, settings)->
  $q.all([
    Companies,
    Cases,
    Coordinates,
  ]).then (datasets)->
    companies   = datasets[0].data
    cases       = datasets[1].data
    coordinates = datasets[2]
    # Remove some victims' juridiction already count as states or provinces
    _.map cases, (kase)=>
      _.extend kase,
        victims: _.filter kase.victims, (j)->
          settings.excludePlaces.indexOf(j.isoa3) is -1
    # Expends and returns every companies
    _.map companies, (company)=>
      # Every codes where this company is incorporated
      incorporations = _.pluck(company.incorporated_in, "isoa3")
      incorporations = incorporations.concat _.pluck company.usincorporated, "i_sous"
      incorporations = incorporations.concat _.pluck company.caincorporated, "i_so"
      # Extend the company with the new data
      _.extend company,
        incorporations: incorporations
        # Remove some juridiction
        incorporated_in: _.filter company.incorporated_in, (j)->
          # Those juridictions are already counted as states or provinces
          settings.excludePlaces.indexOf(j.isoa3) is -1
      # Found cases for this companies
      _.each company.involvement_in_cases, (company_case)->
        # Find the full case object
        _.extend company_case, _.find cases, id: company_case.id
        # Each case made victims in a juridiction;
        # we want to add coordinates to it
        _.each company_case.victims, (case_victim)->
          # Find the coordinates for this juridiction
          victim_coordinates = _.find coordinates, code: case_victim.isoa3
          # Extend the case victims with the coordinates
          _.extend case_victim, victim_coordinates
        # Expend the case too
        _.each company_case.companyinvolvement, (case_company)->
          # Backward relationship to the company
          _.extend case_company, _.find companies, id: case_company.id
      company
    # Add a uniq token to the companies
    companies.hash = do _.uniqueId
    return companies
]

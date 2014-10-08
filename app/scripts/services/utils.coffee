###*
 # @ngdoc service
 # @name gwAnonShellApp.Utils
 # @description
 # # Utils
 # Service in the gwAnonShellApp.
###
angular.module('gwAnonShellApp').factory 'Utils', ["constant.settings", (settings)->
  caseCompaniesJuridictions: (currentCase, companies)->
    # Collect companies juridictions.
    # The following array will be bind to the scope at the end
    # of the collection
    companiesJuridictions = []
    # Analyse every companies involve into this case
    _.each currentCase.companyinvolvement, (company)->
      # Find every data about this company
      _.extend company, _.find(companies, id: company.id)
      # Every juridictions of companies involved in this case
      juridictions = []
      # Collect juridications:
      # 1. by countries
      juridictions = juridictions.concat(
        _.map company.incorporated_in, (j)->
          name: j.name, code: j.isoa3, zone: "WORLD", id: j.id
      )
      # 2. by us states
      juridictions = juridictions.concat(
        _.map company.usincorporated, (j)->
          name: j.name, code: j.i_sous, zone: "USA", id: j.id
      )
      # 3. by canada provinces
      juridictions = juridictions.concat(
        _.map company.caincorporated, (j)->
          name: j.name, code: j.i_so, zone: "CA", id: j.id
      )
      # Save it to the scope for further consultation
      companiesJuridictions = companiesJuridictions.concat juridictions
    # At least, remove duplicates into the juridiction list
    companiesJuridictions = _.uniq companiesJuridictions, "id"
    # Removed exclude juridictions
    # and bind the data to the scope
    _.filter companiesJuridictions, (j)->
      # settings.excludePlaces is a list of excluded codes
      settings.excludePlaces.indexOf(j.code) is -1
]

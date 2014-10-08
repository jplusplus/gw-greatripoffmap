###*
 # @ngdoc function
 # @name gwAnonShellApp.controller:CaseCtrl
 # @description
 # # CaseCtrl
 # Controller of the gwAnonShellApp
###
angular.module('gwAnonShellApp').controller 'CaseCtrl', [
  "$scope", "$timeout", "$document", "Utils", "currentCase", "companies"
  ($scope, $timeout, $document, Utils, currentCase, companies)->
    $scope.case = currentCase
    # Collect companies juridictions.
    $scope.companiesJuridictions = Utils.caseCompaniesJuridictions(currentCase, companies)
    # Wait a small delay before srolling to avoid rendering issue
    $timeout =>
      # Scroll to the top
      $document.scrollToElement angular.element(".header"), 0, 300
    , 500
]

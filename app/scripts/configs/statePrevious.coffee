angular.module('gwAnonShellApp').run ($rootScope, $state)->
  $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromStateParams)->
    $state.previous =
      state: fromState
      params: fromStateParams

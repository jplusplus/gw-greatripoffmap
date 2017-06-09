angular.module('gwAnonShellApp').config [
  'RestangularProvider',
  'constant.api',
  (RestangularProvider,  api)->
    RestangularProvider.setBaseUrl api.base
    RestangularProvider.setRequestSuffix "/"
    RestangularProvider.setResponseExtractor (response, operation)->
      if response.objects?
        response.objects
      else
        response
]

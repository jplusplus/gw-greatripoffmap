describe 'Service: Companies', ->

  # load the service's module
  beforeEach module 'gwAnonShellApp'

  # instantiate service
  Companies = {}
  beforeEach inject (_Companies_) ->
    Companies = _Companies_

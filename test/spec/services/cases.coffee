describe 'Service: Cases', ->

  # load the service's module
  beforeEach module 'gwAnonShellApp'

  # instantiate service
  Cases = {}
  beforeEach inject (_Cases_) ->
    Cases = _Cases_

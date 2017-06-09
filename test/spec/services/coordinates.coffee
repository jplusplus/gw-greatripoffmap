describe 'Service: Coordinates', ->

  # load the service's module
  beforeEach module 'gwAnonShellApp'

  # instantiate service
  Coordinates = {}
  beforeEach inject (_Coordinates_) ->
    Coordinates = _Coordinates_

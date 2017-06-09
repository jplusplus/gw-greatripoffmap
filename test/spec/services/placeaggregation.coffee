describe 'Service: PlaceAggregation', ->

  # load the service's module
  beforeEach module 'gwAnonShellApp'

  # instantiate service
  PlaceAggregation = {}
  beforeEach inject (_PlaceAggregation_) ->
    PlaceAggregation = _PlaceAggregation_

  it 'should do something', ->
    expect(!!PlaceAggregation).toBe true

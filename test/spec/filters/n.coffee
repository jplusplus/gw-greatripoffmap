'use strict'

describe 'Filter: n', ->

  # load the filter's module
  beforeEach module 'gwAnonShellApp'

  # initialize a new instance of the filter before each test
  n = {}
  beforeEach inject ($filter) ->
    n = $filter 'n'

  it 'should return plurazed version of "country"', ->
    text = 'country'
    expect(n(text, 10)).toBe ('countries')

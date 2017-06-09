describe 'Filter: stripTags', ->

  # load the filter's module
  beforeEach module 'gwAnonShellApp'

  # initialize a new instance of the filter before each test
  stripTags = {}
  beforeEach inject ($filter) ->
    stripTags = $filter 'stripTags'

  it 'should return the input prefixed without html tag', ->
    text = '<span>Hello world!</span>'
    expect(stripTags text).toBe ('Hello world!')

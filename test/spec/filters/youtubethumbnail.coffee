describe 'Filter: youtubeThumbnail', ->

  # load the filter's module
  beforeEach module 'gwAnonShellApp'

  # initialize a new instance of the filter before each test
  youtubeThumbnail = {}
  beforeEach inject ($filter) ->
    youtubeThumbnail = $filter 'youtubeThumbnail'

  it 'should return the given youtube url has a thumbnail url', ->
    text = 'https://www.youtube.com/watch?v=jXHKo0lwi3U'
    expect(youtubeThumbnail text).toBe ('http://img.youtube.com/vi/jXHKo0lwi3U/0.jpg')

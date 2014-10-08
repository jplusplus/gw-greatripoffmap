describe 'Service: Tree', ->

  # load the service's module
  beforeEach module 'gwAnonShellApp'

  # instantiate service
  Tree = {}
  beforeEach inject (_Tree_) ->
    Tree = _Tree_

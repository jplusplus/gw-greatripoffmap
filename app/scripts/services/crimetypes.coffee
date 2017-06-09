'use strict'

###*
 # @ngdoc service
 # @name gwAnonShellApp.Crimetypes
 # @description
 # # Crimetypes
 # Service in the gwAnonShellApp.
###
angular.module('gwAnonShellApp').service 'Crimetypes', ["constant.crimetypes", (crimetypes)->
  new class Crimetypes
    trim: (str)-> String(str).replace(/^\s+|\s+$/g, '')
    get: (name='other')=>
      # Normalize name case
      name = name.toLowerCase()
      # Unkown type
      name = "other" unless crimetypes.alias[name]?
      # Find type slug using alias
      slug: crimetypes.alias[name]
      name: crimetypes.name[ crimetypes.alias[name] ]
    getMultiple: (hash='other')=>
      names = hash.split(",")
      slugs = _.map names, (name)=> @get( @trim(name) ).slug
      _.uniq slugs
    getCaseCrimes: (c)=>
      slugs  = @getMultiple c.crimetype
      _.map slugs, @get
]

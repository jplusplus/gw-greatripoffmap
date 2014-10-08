# Karma configuration
# http://karma-runner.github.io/0.12/config/configuration-file.html
# Generated on 2014-07-18 using
# generator-karma 0.8.3

module.exports = (config) ->
  config.set
    # base path, that will be used to resolve files and exclude
    basePath: '../'

    # testing framework to use (jasmine/mocha/qunit/...)
    frameworks: ['jasmine']

    # list of files / patterns to load in the browser
    files: [
      "bower_components/jquery/dist/jquery.js"
      "bower_components/angular/angular.js"
      'bower_components/angular-mocks/angular-mocks.js'
      "bower_components/json3/lib/json3.js"
      "bower_components/angular-sanitize/angular-sanitize.js"
      "bower_components/angular-animate/angular-animate.js"
      "bower_components/angular-touch/angular-touch.js"
      "bower_components/angular-ui-router/release/angular-ui-router.js"
      "bower_components/leaflet/dist/leaflet.js"
      "bower_components/leaflet/dist/leaflet-src.js"
      "bower_components/angular-leaflet-directive/dist/angular-leaflet-directive.js"
      "bower_components/lodash/dist/lodash.compat.js"
      "bower_components/restangular/dist/restangular.js"
      "bower_components/chroma-js/chroma.js"
      "bower_components/leaflet-dvf/index.js"
      "bower_components/d3/d3.js"
      "bower_components/angular-scroll/angular-scroll.min.js"
      "bower_components/angular-truncate/src/truncate.js"
      "bower_components/angular-youtube-mb/src/angular-youtube-embed.js"
      "bower_components/angular-carousel/dist/angular-carousel.js"
      "bower_components/angular-inflector/dist/angular-inflector.min.js"
      'app/scripts/*.coffee'
      'app/scripts/**/*.coffee'
      'test/spec/**/*.coffee'
    ],

    # list of files / patterns to exclude
    exclude: []

    # web server port
    port: 8080

    # level of logging
    # possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
    logLevel: config.LOG_INFO

    # Start these browsers, currently available:
    # - Chrome
    # - ChromeCanary
    # - Firefox
    # - Opera
    # - Safari (only Mac)
    # - PhantomJS
    # - IE (only Windows)
    browsers: [
      'PhantomJS'
    ]

    # Which plugins to enable
    plugins: [
      'karma-phantomjs-launcher'
      'karma-jasmine'
      'karma-coffee-preprocessor'
    ]

    # enable / disable watching file and executing tests whenever any file changes
    autoWatch: true

    # Continuous Integration mode
    # if true, it capture browsers, run tests and exit
    singleRun: false

    colors: true

    preprocessors: '**/*.coffee': ['coffee']

    # Uncomment the following lines if you are using grunt's server to run the tests
    # proxies: '/': 'http://localhost:9000/'
    # URL root prevent conflicts with the site root
    # urlRoot: '_karma_'

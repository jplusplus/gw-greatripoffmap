###*
 # @ngdoc function
 # @name gwAnonShellApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the gwAnonShellApp
###
class MainCtrl
  @$inject: ["$scope", "$state", "$timeout", "$modal", "$window", "Restangular", "Crimetypes", "constant.settings"]
  constructor:(@scope, @state, @timeout, @modal, @window, @Restangular, @Crimetypes, @settings)->
    # State manager available everywhere
    @scope.state = @state
    # type helper
    @scope.crimetype = @Crimetypes.get
    # type helper
    @scope.casecrimes = @Crimetypes.getCaseCrimes
    # Global print function
    @scope.print = @print
    # Global tweet function
    @scope.tweet = @tweet
    # Common function
    @scope.startDownload = =>
      # Start once
      do @download unless @scope.downloadTimeout?
    # Display the share dialog
    @scope.share = @share

  # Simply print the page
  print: =>
    do @window.print if @window.print?
    null

  # Open the share box
  share: =>
    unless @modalInstance?
      @modalInstance = @modal.open
        templateUrl: 'views/share.html'
        controller: 'ShareCtrl'
      @modalInstance.result.finally => delete @modalInstance

  download: =>
    # Try to generate the export file
    @Restangular.one("summary").one("export").get().then (res)=>
      # Export has different status
      switch res.status
        # The download is awaiting
        when "enqueued"
          # Recurcive call of the download function
          @scope.downloadTimeout = @timeout(@download, 2000)
          # Destroy the timeout when living the controller
          @scope.$on '$destroy', => @timeout.cancel(@scope.downloadTimeout)
        # The download is ready
        when "ok"
          # Just download the file
          @window.location.replace res.file_name
          # Remove the timeout
          @scope.downloadTimeout = null

  tweet: =>
    width  = 575
    height = 400
    left   = ($(@window).width()  - width)  / 2
    top    = ($(@window).height() - height) / 2
    text   = 'The Great Rip Off: a map of #anonymous companies and the people they’ve harmed from @global_witness'
    text   = encodeURIComponent(text)
    url    = 'http://twitter.com/share?text=' + text
    url    = url + "&url=" + encodeURIComponent(@settings.url)
    opts   = 'status=1' +
             ',width='  + width  +
             ',height=' + height +
             ',top='    + top    +
             ',left='   + left

    @window.open(url, 'twitter', opts)
    return null


angular.module('gwAnonShellApp').controller 'MainCtrl', MainCtrl

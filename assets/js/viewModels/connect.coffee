do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   fc = window.fannect

   class fc.viewModels.Connect
      constructor: (done) ->
         @load (err, data) =>
            @roster_fans = ko.observableArray data.fans
            if done then done()

      load: (done) ->
         $.mobile.loading "show"
         $.get "#{fc.getResourceURL()}/connect", (data, status) =>
            $.mobile.loading "hide"
            if done then done null, data

do ($ = jQuery, ko = window.ko, fc = window.fannect) ->
   
   class fc.viewModels.Connect.AddToRoster
      constructor: (done) ->
         @load (err, data) =>
            @roster_fans = ko.observableArray data.fans
            if done then done()

      load: (done) ->
         $.mobile.loading "show"
         $.get "#{fc.getResourceURL()}/connect/addToRoster", (data, status) =>
            $.mobile.loading "hide"
            if done then done null, data

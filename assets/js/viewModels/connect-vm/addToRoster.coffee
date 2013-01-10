do ($ = jQuery, ko = window.ko, fc = window.fannect) ->
   
   class fc.viewModels.Connect.AddToRoster
      constructor: (done) ->
         @load (err, data) =>
            @roster_fans = ko.observableArray data.fans
            done err, @

      load: (done) ->
         fc.ajax 
            url: "#{fc.getResourceURL()}/api/connect/addToRoster"
            method: "GET"
         , (xhr, statusText) ->
            done null, xhr


do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Profile.Invitations
      constructor: (done) ->
         @load (err, data) =>
            @invitations = ko.observableArray data.invitations
            done err, @

      load: (done) ->
         $.mobile.loading "show"
         $.get "#{fc.getResourceURL()}/invitations", (data, status) =>
            $.mobile.loading "hide"
            if done then done null, data
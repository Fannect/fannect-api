do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Login
      constructor: () ->
         @email = ko.observable()
         @password = ko.observable()

      login: () ->
         fc.auth.login @email(), @password(), (error) ->
            unless error
               $.mobile.changePage "profile.html", transition: "slideup"

         return false
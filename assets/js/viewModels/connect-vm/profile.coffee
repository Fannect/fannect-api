do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Connect.Profile extends fc.viewModels.Profile
      addToRoster: () ->
         $.mobile.changePage "connect.html", { transition: "slideup" }
         return false
      changeUserImage: () ->
         return false
      changeTeamImage: () -> 
         return false
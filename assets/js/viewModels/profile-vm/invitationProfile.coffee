do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Profile.InvitationProfile extends fc.viewModels.Profile
      acceptInvite: () ->
         $.mobile.changePage "profile.html", { transition: "slideup" }
         return false
      changeUserImage: () ->
         return false #override function to disable changing other persons profile
      changeTeamImage: () -> 
         return false #override function to disable changing other persons profile
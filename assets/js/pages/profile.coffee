do ($ = window.jQuery, ko = window.ko, fc = window.fannect) ->
   $(document).bind "mobileinit", () ->
      $("#profile-page").live("pagecreate", () ->
         new window.fannect.viewModels.Profile (err, vm) =>
            ko.applyBindings vm, @
      )
      
      $("#profile-invitations-page").live("pagecreate", () ->
         new window.fannect.viewModels.Profile.Invitations (err, vm) =>
            ko.applyBindings vm, @
      )      

      $("#profile-invitationProfile-page").live("pagecreate", () ->
         new window.fannect.viewModels.Profile.InvitationProfile (err, vm) =>
            ko.applyBindings vm, @
      )      

      $("#profile-editBio-page").live("pagecreate", () ->
         new window.fannect.viewModels.Profile.EditBio (err, vm) =>
            ko.applyBindings vm, @
      )

      $("#profile-editGameDaySpot-page").live("pagecreate", () ->
         new window.fannect.viewModels.Profile.EditGameDaySpot (err, vm) =>
            ko.applyBindings vm, @
      )

      $("#profile-editBraggingRights-page").live("pagecreate", () ->
         new window.fannect.viewModels.Profile.EditBraggingRights (err, vm) =>
            ko.applyBindings vm, @
      )
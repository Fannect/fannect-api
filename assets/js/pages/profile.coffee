do ($ = window.jQuery, ko = window.ko, fc = window.fannect) ->
   $(document).bind "mobileinit", () ->
      $("#profile-page").live("pageinit", () ->
         new window.fannect.viewModels.Profile (err, vm) =>
            ko.applyBindings vm, @
      )

      $("#profile-editBio-page").live("pageinit", () ->
         new window.fannect.viewModels.Profile.EditBio (err, vm) =>
            ko.applyBindings vm, @
      )

      $("#profile-editGameDaySpot-page").live("pageinit", () ->
         new window.fannect.viewModels.Profile.EditGameDaySpot (err, vm) =>
            ko.applyBindings vm, @
      )

      $("#profile-editBraggingRights-page").live("pageinit", () ->
         new window.fannect.viewModels.Profile.EditBraggingRights (err, vm) =>
            ko.applyBindings vm, @
      )
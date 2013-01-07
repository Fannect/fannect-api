do ($ = window.jQuery, ko = window.ko, fc = window.fannect) ->
   $(document).bind "mobileinit", () ->
      $("#profile-page").live("pagecreate", () ->
         new window.fannect.viewModels.Profile (err, vm) =>
            ko.applyBindings vm, @
      ).live("pageshow", () ->
         fc.showTutorial()
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
do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Profile.EditBraggingRights
      constructor: (done) ->
         fc.user.get (err, data) =>
            @bragging_rights = ko.observable data.bragging_rights
            done err, @

      updateProfile: () ->
         console.log "HIT"
         fc.user.update bragging_rights: @bragging_rights
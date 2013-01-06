do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Profile.EditBio
      constructor: (done) ->
         @bio = ko.observable()

         fc.user.get (err, data) =>
            @bio data.bio
            done err, @

      next: () ->
         console.log "HIT"
         fc.user.update bio: @bio
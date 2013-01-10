do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Profile.EditBio
      constructor: (done) ->
         fc.user.get (err, data) =>
            @bio = ko.observable data.bio
            done err, @

      next: () ->
         fc.user.update bio: @bio
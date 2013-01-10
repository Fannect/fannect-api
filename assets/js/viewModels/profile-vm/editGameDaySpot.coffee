do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Profile.EditGameDaySpot
      constructor: (done) ->
         fc.user.get (err, data) =>
            @game_day_spot = ko.observable data.game_day_spot
            done err, @

      next: () ->
         fc.user.update game_day_spot: @game_day_spot
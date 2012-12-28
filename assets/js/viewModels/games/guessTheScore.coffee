do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   fc = window.fannect

   class fc.viewModels.GuessTheScore
      constructor: (done) ->
         @load (err, data) =>
            @picked_at_load = ko.observable data.picked
            @pick_set = ko.observable data.picked

            @home_score = ko.observable if @picked_at_load then data.home.picked_score else 0
            @away_score = ko.observable if @picked_at_load then data.away.picked_score else 0
            @home_team = data.home.name
            @home_record = data.home.record
            @away_team = data.away.name
            @away_record = data.away.record
            @game_preview = data.game_preview

            @input_valid = ko.computed () =>
               return @home_score() >= 0 and @away_score() >= 0

            if done then done()

      setPick: () ->
         if @input_valid()
            @pick_set true
            # send ajax call to set picked

      load: (done) ->
         $.mobile.loading "show"
         $.get "#{fc.getResourceURL()}/games/guessTheScore", (data, status) ->
            $.mobile.loading "hide"
            done null, data
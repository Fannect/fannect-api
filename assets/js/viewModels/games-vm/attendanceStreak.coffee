do ($ = jQuery, ko = window.ko, fc = window.fannect) ->
   fc.viewModels.Games = {}

   class fc.viewModels.Games.AttendanceStreak
      constructor: (done) ->
         @load (err, data) =>
            @checked_in = ko.observable data.checked_in
            
            @no_game = data.no_game or true
            @next_game = data.next_game
            @stadium_name = data.stadium.name
            @stadium_location = data.stadium.location
            @home_team = data.home.name
            @home_record = data.home.record
            @away_team = data.away.name
            @away_record = data.away.record
            @game_preview = data.game_preview
            done err, @

      checkIn: (data) ->
         @checked_in true
         # ajax call

      load: (done) ->
         $.mobile.loading "show"
         $.get "#{fc.getResourceURL()}/api/games/attendanceStreak", (data, status) ->
            $.mobile.loading "hide"
            done null, data
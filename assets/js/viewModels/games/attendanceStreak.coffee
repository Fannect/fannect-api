do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   fc = window.fannect

   class fc.viewModels.AttendanceStreak
      constructor: (done) ->
         @load (error, data) =>
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

            if done then done()

      checkIn: (data) ->
         @checked_in true
         # ajax call

      load: (done) ->
         $.mobile.loading "show"
         $.get "#{fc.getResourceURL()}/games/attendanceStreak", (data, status) ->
            $.mobile.loading "hide"
            done null, data
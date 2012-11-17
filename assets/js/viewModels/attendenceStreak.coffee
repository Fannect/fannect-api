do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   class window.fannect.viewModels.AttendanceStreak
      constructor: (data) ->
         @checked_in = ko.observable data.checked_in
         @no_game = data.no_game or false
         @next_game = data.next_game

      checkIn: (data) ->
         @checked_in true
         # ajax call
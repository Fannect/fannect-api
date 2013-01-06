do ($ = window.jQuery, ko = window.ko) ->
   setupGuessTheScore = () ->
      $("#games-guessTheScore-page").live("pagecreate", () ->
         scroller = $(".scrolling-text", @).scroller()
         new window.fannect.viewModels.Games.GuessTheScore (err, vm) =>
            ko.applyBindings vm, @
      ).live("pageshow", () ->
         $(".scrolling-text", @).scroller("start")
      ).live "pagebeforehide", () ->
         $(".scrolling-text", @).scroller("stop")

   setupGameFace = () ->
      $("#games-gameFace-page").live("pagecreate", () ->
         $(".scrolling-text", @).scroller()
         new window.fannect.viewModels.Games.GameFace (err, vm) =>
            ko.applyBindings vm, @
      ).live("pageshow", () ->
         $(".scrolling-text", @).scroller("start")
      ).live "pagebeforehide", () ->
         $(".scrolling-text", @).scroller("stop")

   setupAttendanceStreak = () ->
      viewModel = null
      scroller = null
      $("#games-attendanceStreak-page").live("pagecreate", () ->
         scroller = $(".scrolling-text", @).scroller()
         new window.fannect.viewModels.Games.AttendanceStreak (err, vm) =>
            viewModel = vm
            if vm.no_game
               scroller.scroller("start")
            ko.applyBindings vm, @
      ).live("pageshow", () ->
         if viewModel?.no_game then scroller.scroller("start")
      ).live "pagebeforehide", () ->
         scroller.scroller("stop")

   $(document).bind "mobileinit", () ->
      setupGuessTheScore()
      setupGameFace()
      setupAttendanceStreak()

do ($ = window.jQuery, ko = window.ko) ->
   setupGuessTheScore = () ->
      $("#games-guessTheScore-page").live "pagebeforeshow", () ->
         scroller = $(".scrolling-text", @).scroller()
         vm = new window.fannect.viewModels.GuessTheScore () =>
            ko.applyBindings vm, @
            scroller.scroller("start")
      
      $("#games-guessTheScore-page").live "pagebeforehide", () ->
         $(".scrolling-text", @).scroller()

   setupGameFace = () ->
      $("#games-gameFace-page").live "pagebeforeshow", () ->
         vm = new window.fannect.viewModels.GameFace () =>
            ko.applyBindings vm, @
      $("#games-gameFace-page").live("pagebeforeshow", () ->
         $(".scrolling-text", @).scroller()
      ).live("pageshow", () ->
         $(".scrolling-text", @).scroller("start")
      ).live "pagebeforehide", () ->
         $(".scrolling-text", @).scroller("stop")

   setupAttendanceStreak = () ->
      $("#games-attendanceStreak-page").live("pagebeforeshow", () ->
         vm = new window.fannect.viewModels.AttendanceStreak () =>
            if vm.no_game
               scroller = $(".scrolling-text", @).scroller()
               scroller.scroller("start")
            ko.applyBindings vm, @ 
      ).live "pagebeforehide", () ->
         $(".scrolling-text", @).scroller("stop")

   $(document).bind "mobileinit", () ->
      setupGuessTheScore()
      setupGameFace()
      setupAttendanceStreak()

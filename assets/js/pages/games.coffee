do ($ = window.jQuery, ko = window.ko) ->
   setupGuessTheScore = () ->
      $(".games-guessTheScore").live "pagebeforeshow", () ->
         scroller = $(".games-guessTheScore .scrolling-text").scroller()
         vm = new window.fannect.viewModels.GuessTheScore () =>
            ko.applyBindings vm, @
            scroller.scroller("start")
      
      $(".games-guessTheScore").live "pagebeforehide", () ->
         $(".games-guessTheScore .scrolling-text").scroller()

   setupGameFace = () ->
      $(".games-gameFace").live "pagebeforeshow", () ->
         vm = new window.fannect.viewModels.GameFace () =>
            ko.applyBindings vm, @
      $(".games-gameFace").live("pagebeforeshow", () ->
         $(".games-gameFace .scrolling-text").scroller()
      ).live("pageshow", () ->
         $(".games-gameFace .scrolling-text").scroller("start")
      ).live "pagebeforehide", () ->
         $(".games-gameFace .scrolling-text").scroller("stop")

   setupAttendanceStreak = () ->
      vm = null
      $(".games-attendanceStreak").live("pagebeforeshow", () ->
         vm = new window.fannect.viewModels.AttendanceStreak () =>
            if vm.no_game
               scroller = $(".games-attendanceStreak .scrolling-text").scroller()
               scroller.scroller("start")
            ko.applyBindings vm, @ 
      ).live("pageshow", () ->
         # if vm.no_game() then $(".games-attendanceStreak .scrolling-text").scroller("start")
      ).live "pagebeforehide", () ->
         $(".games-attendanceStreak .scrolling-text").scroller("stop")

   $(document).bind "mobileinit", () ->
      setupGuessTheScore()
      setupGameFace()
      setupAttendanceStreak()

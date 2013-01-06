do ($ = window.jQuery, ko = window.ko) ->
   setupGuessTheScore = () ->
      $("#games-guessTheScore-page").live("pagecreate", () ->
         scroller = $(".scrolling-text", @).scroller()
         vm = new window.fannect.viewModels.GuessTheScore () =>
            ko.applyBindings vm, @
      ).live("pageshow", () ->
         $(".scrolling-text", @).scroller("start")
      ).live "pagebeforehide", () ->
         $(".scrolling-text", @).scroller("stop")

   setupGameFace = () ->
      $("#games-gameFace-page").live("pagecreate", () ->
         $(".scrolling-text", @).scroller()
         vm = new window.fannect.viewModels.GameFace () =>
            ko.applyBindings vm, @
      ).live("pageshow", () ->
         $(".scrolling-text", @).scroller("start")
      ).live "pagebeforehide", () ->
         $(".scrolling-text", @).scroller("stop")

   setupAttendanceStreak = () ->
      vm = null
      scroller = null
      $("#games-attendanceStreak-page").live("pagecreate", () ->
         scroller = $(".scrolling-text", @).scroller()
         vm = new window.fannect.viewModels.AttendanceStreak () =>
            if vm.no_game
               scroller.scroller("start")
            ko.applyBindings vm, @
      ).live("pageshow", () ->
         if vm?.no_game then scroller.scroller("start")
      ).live "pagebeforehide", () ->
         scroller.scroller("stop")

   $(document).bind "mobileinit", () ->
      setupGuessTheScore()
      setupGameFace()
      setupAttendanceStreak()

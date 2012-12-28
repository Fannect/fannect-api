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
      $(".games-attendanceStreak").live("pagebeforeshow", () ->
         attend = window.fannect.attendance_streak
         if attend.no_game
            scroller = $(".games-attendanceStreak .scrolling-text").scroller()
         vm = new window.fannect.viewModels.AttendanceStreak attend
         ko.applyBindings vm, this 
      ).live "pageshow", () ->
         if window.fannect.attendance_streak.no_game
            $(".games-attendanceStreak .scrolling-text").scroller("start")

   $(document).bind "mobileinit", () ->
      setupGuessTheScore()
      setupGameFace()
      setupAttendanceStreak()

      # $(".games-gameFace-gameDay").live "pageinit", () ->
      #    $(".games-gameFace-gameDay #gameFaceSwitch").live "change", () ->
      #       $el = $(this)
      #       if  $el.val() == "on"
      #          $(".games-gameFace-gameDay .game-face").addClass("on")
      #       else
      #          $(".games-gameFace-gameDay .game-face").removeClass("on")

      
      

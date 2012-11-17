do ($ = window.jQuery, ko = window.ko) ->
   setupGuessTheScore = () ->
      $(".points-guessTheScore-pick").live "pagebeforeshow", () ->
         scroller = $(".points-guessTheScore-pick .scrolling-text").scroller()
         viewModel = new window.fannect.viewModels.GuessTheScore()
         ko.applyBindings viewModel, this
         scroller.scroller("start")
      
      $(".points-guessTheScore-pick").live "pagebeforehide", () ->
         $(".points-guessTheScore-pick .scrolling-text").scroller()

   setupGameFace = () ->
      $(".points-gameFace-gameDay").live "pagebeforeshow", () ->
         viewModel = new window.fannect.viewModels.GameFace()
         ko.applyBindings viewModel, this
      $(".points-gameFace-noGame").live("pagebeforeshow", () ->
         $(".points-gameFace-noGame .scrolling-text").scroller()
      ).live("pageshow", () ->
         $(".points-gameFace-noGame .scrolling-text").scroller("start")
      ).live "pagebeforehide", () ->
         $(".points-gameFace-noGame .scrolling-text").scroller("stop")

   setupAttendanceStreak = () ->
      $(".points-attendanceStreak").live("pagebeforeshow", () ->
         attend = window.fannect.attendance_streak
         if attend.no_game
            scroller = $(".points-attendanceStreak .scrolling-text").scroller()
         vm = new window.fannect.viewModels.AttendanceStreak attend
         ko.applyBindings vm, this 
      ).live "pageshow", () ->
         if window.fannect.attendance_streak.no_game
            $(".points-attendanceStreak .scrolling-text").scroller("start")

   $(document).bind "mobileinit", () ->
      setupGuessTheScore()
      setupGameFace()
      setupAttendanceStreak()

      # $(".points-gameFace-gameDay").live "pageinit", () ->
      #    $(".points-gameFace-gameDay #gameFaceSwitch").live "change", () ->
      #       $el = $(this)
      #       if  $el.val() == "on"
      #          $(".points-gameFace-gameDay .game-face").addClass("on")
      #       else
      #          $(".points-gameFace-gameDay .game-face").removeClass("on")

      
      

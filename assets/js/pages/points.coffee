$ = window.jQuery
showMenu = () ->
   window.fannect.setActiveMenu("points")

setupGuessTheScore = () ->
   $(".points-guessTheScore-pick").live "pagebeforeshow", () ->
      showMenu()
      $(".points-guessTheScore-pick .scrolling-text").scroller()
   
   $(".points-guessTheScore-pick .submit-guess").live "click", () ->
      homeInput = $(".points-guessTheScore-pick .home input")
      homeValue = $(".points-guessTheScore-pick .home .value")
      awayInput = $(".points-guessTheScore-pick .away input")
      awayValue = $(".points-guessTheScore-pick .away .value")
      homeValue.text homeInput.val()
      awayValue.text awayInput.val()
      homeValue.fadeIn 400, () -> homeInput.hide()
      awayValue.fadeIn 400, () -> awayInput.hide()
      
      $(".points-guessTheScore-pick .picking").hide()
      $(".points-guessTheScore-pick .picked").fadeIn 400
      $(".points-guessTheScore-pick .scrolling-text").scroller("start")

      return false

$(document).bind "mobileinit", () ->
   $(".points-points").live "pagebeforeshow", showMenu
   $(".points-attendanceStreak").live "pagebeforeshow", showMenu
   $(".points-gameFace-gameDay").live "pagebeforeshow", showMenu
   $(".points-suggestGame").live "pagebeforeshow", showMenu
      
   setupGuessTheScore()


   $(".points-guessTheScore-picked").live("pagebeforeshow", () ->
      showMenu()
      $(".points-guessTheScore-picked .scrolling-text").scroller()
   ).live("pageshow", () ->
      $(".points-guessTheScore-picked .scrolling-text").scroller("start")
   ).live "pagebeforehide", () ->
      $(".points-guessTheScore-picked .scrolling-text").scroller("stop")

   $(".points-gameFace-gameDay").live "pageinit", () ->
      $(".points-gameFace-gameDay #gameFaceSwitch").live "change", () ->
         $el = $(this)
         if  $el.val() == "on"
            $(".points-gameFace-gameDay .game-face").addClass("on")
         else
            $(".points-gameFace-gameDay .game-face").removeClass("on")

   $(".points-gameFace-noGame").live("pagebeforeshow", () ->
      showMenu()
      $(".points-gameFace-noGame .scrolling-text").scroller()
   ).live("pageshow", () ->
      $(".points-gameFace-noGame .scrolling-text").scroller("start")
   ).live "pagebeforehide", () ->
      $(".points-gameFace-noGame .scrolling-text").scroller("stop")

   

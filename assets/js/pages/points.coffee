$ = window.jQuery
showMenu = () ->
   fannect.setActiveMenu("points")

$(document).bind "mobileinit", () ->
   $(".points-points").live "pagebeforeshow", showMenu
   $(".points-guessTheScore-pick").live "pagebeforeshow", showMenu
   $(".points-attendanceStreak").live "pagebeforeshow", showMenu
   $(".points-gameFace-gameDay").live "pagebeforeshow", showMenu
   $(".points-suggestGame").live "pagebeforeshow", showMenu
   $(".points-guessTheScore-picked").live "pagebeforeshow", showMenu
      
   $(".points-guessTheScore-picked").live "pageshow", () ->
      $(".points-guessTheScore-picked .scrolling-text").scroller()

   $(".points-gameFace-gameDay").live "pageinit", () ->
      $(".points-gameFace-gameDay #gameFaceSwitch").live "change", () ->
         $el = $(this)
         if  $el.val() == "on"
            $(".points-gameFace-gameDay .game-face").addClass("on")
         else
            $(".points-gameFace-gameDay .game-face").removeClass("on")

   $(".points-gameFace-noGame").live "pageshow", () ->
      $(".points-gameFace-noGame .scrolling-text").scroller()
      # $(".points-gameFace-noGame .content .scrolling-text").scroller();

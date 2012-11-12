showMenu = () ->
   fannect.setActiveMenu("points")

$(document).bind "mobileinit", () ->
   $(".points-points").live "pagebeforeshow", showMenu
   $(".points-guessTheScore-pick").live "pagebeforeshow", showMenu
   $(".points-guessTheScore-picked").live "pagebeforeshow", showMenu
   $(".points-attendanceStreak").live "pagebeforeshow", showMenu
   $(".points-gameFace").live "pagebeforeshow", showMenu
   $(".points-suggestGame").live "pagebeforeshow", showMenu
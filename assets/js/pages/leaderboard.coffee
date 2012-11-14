showMenu = () ->
   window.fannect.setActiveMenu("leaderboard")

$(document).bind "mobileinit", () ->
   $(".leaderboard-leaderboard").live "pagebeforeshow", showMenu
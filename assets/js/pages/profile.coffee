showMenu = () ->
   fannect.setActiveMenu("profile")

$(document).bind "mobileinit", () ->
   $(".profile-profile").live "pagebeforeshow", showMenu
   $(".profile-selectSport").live "pagebeforeshow", showMenu
   $(".profile-selectLeague").live "pagebeforeshow", showMenu
   $(".profile-selectTeam").live "pagebeforeshow", showMenu
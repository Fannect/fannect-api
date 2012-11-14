showMenu = () ->
   window.fannect.setActiveMenu("connect")

$(document).bind "mobileinit", () ->
   $(".connect-connect").live "pagebeforeshow", showMenu
showMenu = () ->
   fannect.setActiveMenu("preferences")

$(document).bind "mobileinit", () ->
   $(".preferences-preferences").live "pagebeforeshow", showMenu
   $(".preferences-account").live "pagebeforeshow", showMenu
   $(".preferences-support").live "pagebeforeshow", showMenu
   $(".preferences-aboutFannect").live "pagebeforeshow", showMenu
   $(".preferences-aboutFullTiltVentures").live "pagebeforeshow", showMenu
   $(".preferences-aboutRadeEccles").live "pagebeforeshow", showMenu
   $(".preferences-privacy").live "pagebeforeshow", showMenu
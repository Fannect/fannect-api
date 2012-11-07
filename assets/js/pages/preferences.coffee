showMenu = () ->
   fannect.setActiveMenu("preferences")

$(document).bind "mobileinit", () ->
   $(".preferences-preferences").live "pageshow", (event) ->
      showMenu()

   $(".preferences-support").live "pageshow", showMenu
   # $(".preferences-support").live "pageshow", showMenu
   # $(".preferences-support").live "pageshow", showMenu
   # $(".preferences-support").live "pageshow", showMenu
   # $(".preferences-support").live "pageshow", showMenu
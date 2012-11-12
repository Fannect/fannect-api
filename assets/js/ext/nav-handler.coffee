unless window.fannect then window.fannect = {}

window.fannect.setActiveMenu = (menu) ->
   $(".footer .ui-btn-active").removeClass("ui-btn-active").removeClass("ui-btn-persist")
   $(".footer ." + menu + "-menu").addClass("ui-btn-active").addClass("ui-btn-persist")

unless window.fannect then window.fannect = {}

window.fannect.setActiveMenu = (menu) ->
   $(".footer .ui-btn-active").removeClass("ui-btn-active").removeClass("ui-btn-persist")
   $(".footer ." + menu + "-menu").addClass("ui-btn-active").addClass("ui-btn-persist")

window.fannect.isPhoneGap = () -> 
   return document.URL.indexOf("http://") == -1 and document.URL.indexOf("https://") == -1

window.fannect.getResourceURL = () ->
   if window.fannect.isPhoneGap() then "http://fannect.me" else ""
window.fannect = window.fannect or {}

window.fannect.setActiveMenu = (menu) ->
   $(".footer .ui-btn-active").removeClass("ui-btn-active").removeClass("ui-btn-persist")
   $(".footer ." + menu + "-menu").addClass("ui-btn-active").addClass("ui-btn-persist")

window.fannect.isPhoneGap = () -> 
   return document.URL.indexOf("http://") == -1 and document.URL.indexOf("https://") == -1

window.fannect.getResourceURL = () ->
   if window.fannect.isPhoneGap() then "http://fannect.herokuapp.com" else ""

window.fannect.getParams = () ->
   if window.fannect.isPhoneGap()
      return $.url($.url().fsegment(1)).param()
   else
      return $.url().param() 


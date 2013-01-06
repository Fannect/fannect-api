do ($ = window.jQuery, ko = window.ko) ->
   currentUser = null

   fc = window.fannect = 
      viewModels: {}

   fc.setActiveMenu = (menu) ->
      $(".footer .ui-btn-active").removeClass("ui-btn-active").removeClass("ui-btn-persist")
      $(".footer ." + menu + "-menu").addClass("ui-btn-active").addClass("ui-btn-persist")

   fc.isPhoneGap = () -> 
      return document.URL.indexOf("http://") == -1 and document.URL.indexOf("https://") == -1

   fc.getResourceURL = () ->
      if fc.isPhoneGap() then "http://fannect.herokuapp.com" else ""

   fc.getParams = () ->
      if fc.isPhoneGap()
         return $.url($.url().fsegment(1)).param()
      else
         return $.url().param() 

   fc.clearBindings = (context) ->
      ko.cleanNode context

   fc.user =
      get: (done) ->
         if currentUser 
            done null, currentUser
         else
            $.mobile.loading "show"
            $.get "#{fc.getResourceURL()}/profile", (data, status) ->
               $.mobile.loading "hide"
               currentUser = data
               done null, data

      update: (user) ->
         $.extend true, currentUser, user

      save: (user) ->
         if user then fc.user.update user
         # implement saving


   # fc.saveUser = (done) ->
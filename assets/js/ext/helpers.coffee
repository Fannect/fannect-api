do ($ = window.jQuery, ko = window.ko) ->
   $.cookie.json = true
   currentUser = null
   currentCookie = null

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

   fc.showTutorial = () ->
      $tutorial = $(".tutorial", $.mobile.activePage).fadeIn(400)
      
      unless $tutorial.data("tutorial_is_init")
         if $tutorial.children(".tutorial-slider.one").length < 1
            tutorial = $tutorial.get(0)
            slider = new Swipe(tutorial, speed: 500)
            $tutorial.data("tutorial_is_init", true)

            $(".tutorial-next", tutorial).click (e) ->
               e.stopPropagation()
               slider.next()
            $(".tutorial-prev", tutorial).click (e) ->
               e.stopPropagation()
               slider.prev()

         $(".tutorial-close", tutorial).click (e) ->
            e.stopPropagation()
            fc.hideTutorial()

   fc.hideTutorial = () ->
      $(".tutorial", $.mobile.activePage).fadeOut(400)

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

   fc.cookie = 
      get: () ->
         unless currentCookie
            currentCookie = $.cookie("fannect_cached")
         return currentCookie or {}
      update: (data) ->
         $.extend true, currentCookie, data
         return currentCookie
      save: (data) ->
         if data 
            fc.cookie.update data
         cookieData = fc.cookie.get()
         $.cookie("fannect_cached", cookieData, { expires: 365, path: '/' });
         return cookieData

   fc.auth =
      login: (email, pw, done) ->
         query = { email: email, password: pw }
         $.mobile.loading "show"
         $.post "#{fc.getResourceURL()}/login", query, (data, status) ->
            $.mobile.loading "hide"
            if data.status == "success"
               delete data.status 
               fc.cookie.save(data)
               done null, data 
            else
               done data.error_message
      isLoggedIn: () ->
         return fc.cookie.get().refresh_token?
      checkLogin: () ->
         noAuth = ["index-page", "createAccount-page"]
         if not fc.auth.isLoggedIn() and not ($.mobile.activePage.id in noAuth)
            $.mobile.changePage "index.html", transition: "slidedown"
            return false
         return true

do ($ = window.jQuery, ko = window.ko) ->
   $.cookie.json = true
   currentUser = null
   currentCookie = null
   currentForceClient = null
   client_id = "3MVG9y6x0357Hlef0sJ1clNGWyYjGIN0fGQjmzawi2ojX6xQ_4MbJ7l1Xbl54iZcWCdFd5N1FTepUjq3DX12L"

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

   fc.ajax = (settings, done) ->
      $.mobile.loading "show"
      return $.ajax(settings).always (xhr, textStatus) ->
         $.mobile.loading "hide"
         if xhr.status == 401
            redirectToLogin()
         else
            if done then done xhr, textStatus

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

   fc.getForceClient = () ->
      unless currentForceClient 
         auth = fc.cookie.get().auth
         access_token = auth.access_token
         instance_url = auth.instance_url
         if not access_token? or not instance_url
            throw "Must have access_token and instance_url before creating client_id"
         
         currentForceClient = new window.forcetk.Client(client_id, access_token, instanceUrl)

      return currentForceClient

   fc.user =
      get: (done) ->
         if currentUser 
            done null, currentUser
         else
            fc.ajax 
               url: "#{fc.getResourceURL()}/api/profile"
               method: "GET"
            , (xhr, statusText) ->
               currentUser = xhr
               done null, xhr

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
         $.post "#{fc.getResourceURL()}/api/login", query, (data, status) ->
            $.mobile.loading "hide"
            if data.status == "success" then done()
            else done data.error_message
      
      isLoggedIn: () ->
         return fc.cookie.get().refresh_token?
      
      redirectToLogin: () ->
         noAuth = ["index-page", "createAccount-page"]
         if not ($.mobile.activePage.id in noAuth)
            $.mobile.changePage "index.html", transition: "slidedown"

do ($ = window.jQuery, fc = window.fannect) ->

   $(document).on "mobileinit", () ->
      $.mobile.allowCrossDomainPages = true
      $.mobile.pushStateEnabled = false if fc.isPhoneGap()
      if $.support.touch and not $.support.touchOverflow
         $("body").addClass("speed-up")

   $(".ui-page").live("pagebeforeshow", () ->
      # check if logged in
      # unless fc.auth.checkLogin() then return
      
      # set menu
      $el = $(@)
      menu = getMenu($el)
      if menu
         $(".footer .ui-btn-active").removeClass("ui-btn-active").removeClass("ui-btn-persist")
         $(".footer ." + menu + "-menu").addClass("ui-btn-active").addClass("ui-btn-persist")

   ).live("pageshow", () ->
      tutorial_pages = [ "profile-page", "games-attendanceStreak-page", "games-gameFace-page", "games-guessTheScore-page" ]
      currentId = $($.mobile.activePage).attr("id")
      cookie = fc.cookie.get()
      cookie.tutorialShown = cookie.tutorialShown or []

      if currentId in tutorial_pages and not (currentId in cookie.tutorialShown)
         cookie.tutorialShown.push currentId
         fc.showTutorial()
         fc.cookie.save cookie

   ).live "pageremove", () ->
      fc.clearBindings @

   $(".tutorial-link").live "click", (e) ->
      e.stopPropagation()
      fc.showTutorial()
      return false
      
   getMenu = (page) ->
      if menuFn = custom_menu_setter[page.attr("id")]
         return menuFn()
      else
         return page.children(".header").first().children("h1").attr("data-menu-root")

   custom_menu_setter = {}
      # "profile-page": () ->
      #    params = fc.getParams() 
      #    if params.user then "connect" else "profile" 
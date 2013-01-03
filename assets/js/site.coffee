do ($ = window.jQuery) ->

   $(document).on "mobileinit", () ->
      $.mobile.allowCrossDomainPages = true
      $.mobile.pushStateEnabled = false if window.fannect.isPhoneGap()
      if $.support.touch and not $.support.touchOverflow
         $("body").addClass("speed-up")

   $(".index.ui-page").live "pageshow", () ->
      $.mobile.changePage("profile.html")
   $(".ui-page").live "pagebeforeshow", () ->
      $el = $(@)
      menu = getMenu($el)
      if menu
         $(".footer .ui-btn-active", $el).removeClass("ui-btn-active").removeClass("ui-btn-persist")
         $(".footer ." + menu + "-menu", $el).addClass("ui-btn-active").addClass("ui-btn-persist")
   
   getMenu = (page) ->
      if menuFn = custom_menu_setter[page.attr("id")]
         return menuFn()
      else
         return page.children(".header").first().children("h1").attr("data-menu-root")

   custom_menu_setter =
      "profile-page": () ->
         params = window.fannect.getParams()
         if params.user then "connect" else "profile" 
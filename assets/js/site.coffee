do ($ = window.jQuery) ->
   $(document).on "mobileinit", () ->
      $.mobile.allowCrossDomainPages = true
      $.mobile.pushStateEnabled = false if window.fannect.isPhoneGap()

   $(".index.ui-page").live "pageshow", () ->
      $.mobile.changePage("profile.html")
   $(".ui-page").live("pagebeforeshow", () ->
      menu = $(this).children(".header").first().children("h1").attr("data-menu-root")
      if menu
         $(".footer .ui-btn-active").removeClass("ui-btn-active").removeClass("ui-btn-persist")
         $(".footer ." + menu + "-menu").addClass("ui-btn-active").addClass("ui-btn-persist")
   ).live "pageshow", () ->
      if $.support.touch and not $.support.touchOverflow
         $("body").addClass("speed-up")

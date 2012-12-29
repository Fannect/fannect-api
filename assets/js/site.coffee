do ($ = window.jQuery) ->
   $(document).on "mobileinit", () ->
      $.mobile.allowCrossDomainPages = true
      $.mobile.pushStateEnabled = false if window.fannect.isPhoneGap()

   scrollbars = []
   $(".index.ui-page").live "pageshow", () ->
      $.mobile.changePage("profile.html")
   $(".ui-page").live("pagebeforeshow", () ->
      menu = $(this).children(".header").first().children("h1").attr("data-menu-root")
      if menu
         $(".footer .ui-btn-active").removeClass("ui-btn-active").removeClass("ui-btn-persist")
         $(".footer ." + menu + "-menu").addClass("ui-btn-active").addClass("ui-btn-persist")
   ).live("pageshow", () ->
      if $.support.touch and not $.support.touchOverflow
         $("body").addClass("speed-up")
         $(".scrollable-content").each (i) ->
            scrollbars.push new iScroll this, momentum: false
   ).live "pagebeforehide", () ->
         for bar in scrollbars
            bar.destroy()
         scrollbars.length = 0

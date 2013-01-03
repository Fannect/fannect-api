do ($ = window.jQuery, ko = window.ko) ->
   # teamScrollbar = null
   # nextBtn = null
   # prevBtn = null

   $(document).bind "mobileinit", () ->
      $("#profile-page").live("pagebeforeshow", () ->
         scroller = $(".scrolling-text", @).scroller()
         
         vm = new window.fannect.viewModels.Profile () =>
            ko.applyBindings vm, @
            scroller.scroller("start")
      )
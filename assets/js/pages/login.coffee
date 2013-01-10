do ($ = window.jQuery, ko = window.ko, fc = window.fannect) ->
   $(document).bind "mobileinit", () ->
      $("#index-page").live("pagecreate", () ->
         ko.applyBindings new window.fannect.viewModels.Login(), @
      ).live("pagebeforeshow", () ->
         if fc.auth.isLoggedIn()
            $.mobile.changePage "profile.html", transition: "none"
      )
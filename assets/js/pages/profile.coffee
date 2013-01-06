do ($ = window.jQuery, ko = window.ko, fc = window.fannect) ->
   $(document).bind "mobileinit", () ->
      $("#profile-page").live("pagecreate", () ->
         vm = new window.fannect.viewModels.Profile () =>
            ko.applyBindings vm, @
      )
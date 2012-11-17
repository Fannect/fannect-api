do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   class window.fannect.viewModels.Connect
      constructor: (data) ->
         @roster_fans = ko.observableArray data

do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   fc = window.fannect

   class fc.viewModels.GameFace
      constructor: (done) ->
         @face_value = ko.observable("off")
         @face_on = ko.computed () =>
            return @face_value()?.toLowerCase() == "on"
         
         if data?.face_on
            @face_value("on")

         @face_on.subscribe (newValue) ->
            #ajax call


      load: (done) ->
         $.mobile.loading "show"
         $.get "#{fc.getResourceURL()}/games/gameFace", (data, status) ->
            $.mobile.loading "hide"
            done null, data
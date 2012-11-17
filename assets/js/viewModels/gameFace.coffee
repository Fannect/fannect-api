do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   class window.fannect.viewModels.GameFace
      constructor: (data) ->
         @face_value = ko.observable("off")
         @face_on = ko.computed () =>
            return @face_value()?.toLowerCase() == "on"
         
         if data?.face_on
            @face_value("on")

         @face_on.subscribe (newValue) ->
            #ajax call
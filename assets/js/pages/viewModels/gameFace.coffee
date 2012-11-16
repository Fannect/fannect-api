do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   viewModels = window.fannect.viewModels

   class viewModels.gameFace
      constructor: (data) ->
         @face_value = ko.observable("off")
         @face_on = ko.computed () =>
            return @face_value()?.toLowerCase() == "on"
         
         if data?.face_on
            @face_value("on")

         @face_on.subscribe (newValue) ->
            console.log "SUB: ", newValue
do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   viewModels = window.fannect.viewModels

   class viewModels.guessTheScore
      constructor: (data) ->
         @on = ko.observable data?.on

      switched: () ->
         @on !@on()
         # send ajax call to set picked
do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   class window.fannect.viewModels.GuessTheScore
      constructor: (data) ->
         @picked_at_load = ko.observable data?.pick_set
         @pick_set = ko.observable data?.pick_set
         @home_score = ko.observable data?.home_score 
         @away_score = ko.observable data?.away_score 
         @input_valid = ko.computed () =>
            return @home_score() >= 0 and @away_score() >= 0


      setPick: () ->
         if @input_valid()
            @pick_set true
            # send ajax call to set picked
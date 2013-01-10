do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Games.GameFace
      constructor: (done) ->
         
         @load (err, data) =>            
            @face_value = ko.observable("off")
            @face_on = ko.computed () => @face_value()?.toLowerCase() == "on"
            @available = ko.observable false
            if data.available
               @available true
               @face_value data?.face_value
            else 
               @available false
               @face_value "off"

            @home_team = data.home.name
            @home_record = data.home.record
            @away_team = data.away.name
            @away_record = data.away.record

            @face_on.subscribe (newValue) ->
               #ajax call

            done err, @

      load: (done) ->
         fc.ajax 
            url: "#{fc.getResourceURL()}/api/games/gameFace"
            method: "GET"
         , (xhr, statusText) ->
            done null, xhr
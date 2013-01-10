do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Leaderboard
      constructor: (done) ->
         @overall_loaded =  false
         @roster_loaded =  false
         @selected_view = ko.observable("overall")
         @is_overall_selected = ko.computed () => return @selected_view() == "overall"
         @is_roster_selected = ko.computed () => return @selected_view() == "roster"
         @roster_fans = ko.observableArray()
         @overall_fans = ko.observableArray()

         @selected_view.subscribe @viewToggled
         @loadOverall (err, data) =>
            done err, @

      viewToggled: () =>
         if @selected_view() == "roster" and not @roster_loaded then @loadRoster()
         else if @selected_view() == "overall" and not @overall_loaded then @loadOverall()

      loadOverall: (done) ->
         fc.ajax 
            url: "#{fc.getResourceURL()}/api/leaderboard?type=overall"
            method: "GET"
         , (data, statusText) =>
            @overall_fans.push fan for fan in data.fans
            @overall_loaded = true
            if done then done null, data

      loadRoster: (done) ->
         fc.ajax 
            url: "#{fc.getResourceURL()}/api/leaderboard?type=roster"
            method: "GET"
         , (data, statusText) =>
            @roster_fans.push fan for fan in data.fans
            @roster_loaded = true
            $.mobile.loading "hide"
            if done then done null, data
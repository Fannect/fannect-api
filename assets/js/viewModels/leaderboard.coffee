do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   fc = window.fannect

   class fc.viewModels.Leaderboard
      constructor: (done) ->
         @overall_loaded =  false
         @roster_loaded =  false
         @selected_view = ko.observable("overall")
         @is_overall_selected = ko.computed () => return @selected_view() == "overall"
         @is_roster_selected = ko.computed () => return @selected_view() == "roster"
         @roster_fans = ko.observableArray()
         @overall_fans = ko.observableArray()
         @force_overall_list_update = ko.observable 0
         @force_roster_list_update = ko.observable 0

         @loadOverall done
         @selected_view.subscribe @viewToggled

      viewToggled: () =>
         if @selected_view() == "roster" and not @roster_loaded then @loadRoster()
         else if @selected_view() == "overall" and not @overall_loaded then @loadOverall()

      loadOverall: (done) ->
         $.mobile.loading "show"
         $.get "#{fc.getResourceURL()}/leaderboard?type=overall", (data, status) =>
            @overall_fans.push fan for fan in data.fans
            @overall_loaded = true
            $.mobile.loading "hide"
            @force_overall_list_update @force_overall_list_update()+1
            if done then done null, data

      loadRoster: (done) ->
         $.mobile.loading "show"
         $.get "#{fc.getResourceURL()}/leaderboard?type=roster", (data, status) =>
            @roster_fans.push fan for fan in data.fans
            @roster_loaded = true
            $.mobile.loading "hide"
            @force_roster_list_update @force_roster_list_update()+1
            if done then done null, data
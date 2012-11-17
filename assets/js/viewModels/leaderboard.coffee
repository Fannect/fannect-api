do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   class window.fannect.viewModels.leaderboard
      constructor: (data) ->
         @selected_view = ko.observable("overall")
         @is_overall_selected = ko.computed () => return @selected_view() == "overall"
         @roster_fans = ko.observableArray data.roster_fans
         @overall_fans = ko.observableArray data.overall_fans

      toggleView: () ->
         @is_overall_selected !@is_overall_selected()

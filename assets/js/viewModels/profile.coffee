do ($ = jQuery, ko = window.ko) ->
   unless window.fannect then window.fannect = {}
   unless window.fannect.viewModels then window.fannect.viewModels = {}

   fc = window.fannect

   class fc.viewModels.Profile
      constructor: (done) ->
         @load (err, data) =>
            @name = ko.observable name
            @team_image = ko.observable data.team_image
            @user_image = ko.observable data.user_image
            @teams = ko.observableArray data.teams
            @roster = ko.observable data.score.roster
            @points = ko.observable data.score.points
            @rank = ko.observable data.score.rank
            @bio = ko.observable data.personal.bio
            @game_day_spot = ko.observable data.personal.game_day_spot
            @bragging_rights = ko.observable data.personal.bragging_rights
            done()

      load: (done) ->
         $.mobile.loading "show"
         $.get "#{fc.getResourceURL()}/profile", (data, status) ->
            $.mobile.loading "hide"
            done null, data
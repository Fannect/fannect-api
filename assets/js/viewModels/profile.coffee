do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Profile
      constructor: (done) ->
         @load (err, data) =>
            @name = ko.observable name
            @team_image = ko.observable data.team_image or ""
            @user_image = ko.observable data.user_image or ""
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

      changeUserImage: () ->
         alert "USER"
      changeTeamImage: () -> 
         alert "TEAM"
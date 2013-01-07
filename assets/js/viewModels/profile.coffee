do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Profile
      constructor: (done) ->
         fc.user.get (err, data) =>
            @name = ko.observable data.name
            @team_image = ko.observable data.team_image or ""
            @user_image = ko.observable data.user_image or ""
            @teams = ko.observableArray data.teams
            @roster = ko.observable data.roster
            @points = ko.observable data.points
            @rank = ko.observable data.rank
            @bio = ko.observable data.bio
            @game_day_spot = ko.observable data.game_day_spot
            @bragging_rights = ko.observable data.bragging_rights
            done err, @

      changeUserImage: (data, e) ->
         alert "USER"
      changeTeamImage: (data, e) -> 
         alert "TEAM"
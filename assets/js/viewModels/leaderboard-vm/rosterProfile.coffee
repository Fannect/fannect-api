do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Leaderboard.RosterProfile extends fc.viewModels.Profile
      constructor: (done) ->      
         console.log "Leaderboard"
         @checkIfOnRoster (err, on_roster) =>
            @on_roster = ko.observable on_roster
            super done

      checkIfOnRoster: (done) ->
         done null, false

      sendInvite: () ->
         return false #send invitation
         
      changeUserImage: () ->
         return false #override function to disable changing other persons profile
      changeTeamImage: () -> 
         return false #override function to disable changing other persons profile
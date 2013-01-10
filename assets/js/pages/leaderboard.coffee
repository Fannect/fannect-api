$(document).bind "mobileinit", () ->
   $("#leaderboard-page").live "pagecreate", () ->
      new window.fannect.viewModels.Leaderboard (err, vm) =>
         ko.applyBindings vm, @

   $("#leaderboard-rosterProfile-page").live "pagecreate", () ->
      new window.fannect.viewModels.Leaderboard.RosterProfile (err, vm) =>
         ko.applyBindings vm, @
$(document).bind "mobileinit", () ->
   $(".leaderboard-leaderboard").live "pagebeforeshow", () ->
      ko.applyBindings new window.fannect.viewModels.Leaderboard(window.fannect.leaderboard), this
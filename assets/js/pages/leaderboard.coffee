$(document).bind "mobileinit", () ->
   $(".leaderboard-leaderboard").live "pagebeforeshow", () ->
      ko.applyBindings new window.fannect.viewModels.leaderboard(window.fannect.leaderboard), this
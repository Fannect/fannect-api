$(document).bind "mobileinit", () ->
   $(".leaderboard-leaderboard").live "pagebeforeshow", () ->
      console.log window.fannect.viewModels.leaderboard
      ko.applyBindings new window.fannect.viewModels.leaderboard(window.fannect.leaderboard), this
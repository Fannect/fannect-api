$(document).bind "mobileinit", () ->
   $(".leaderboard").live "pagebeforeshow", () ->
      vm = new window.fannect.viewModels.Leaderboard () =>
         ko.applyBindings vm, @
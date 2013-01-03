$(document).bind "mobileinit", () ->
   $("#leaderboard-page").live "pagebeforeshow", () ->
      vm = new window.fannect.viewModels.Leaderboard () =>
         ko.applyBindings vm, @
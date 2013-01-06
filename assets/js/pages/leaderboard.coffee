$(document).bind "mobileinit", () ->
   $("#leaderboard-page").live "pagecreate", () ->
      vm = new window.fannect.viewModels.Leaderboard () =>
         ko.applyBindings vm, @
$(document).bind "mobileinit", () ->
   $("#connect-page").live "pagebeforeshow", () ->
      vm = new window.fannect.viewModels.Connect () =>
         ko.applyBindings vm, @
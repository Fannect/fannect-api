$(document).bind "mobileinit", () ->
   $(".connect.ui-page").live "pagebeforeshow", () ->
      vm = new window.fannect.viewModels.Connect () =>
         ko.applyBindings vm, @
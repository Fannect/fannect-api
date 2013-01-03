$(document).bind "mobileinit", () ->
   $("#connect-page").live "pagebeforeshow", () ->
      vm = new window.fannect.viewModels.Connect () =>
         ko.applyBindings vm, @
   $("#connect-addToRoster-page").live "pagebeforeshow", () ->
      vm = new window.fannect.viewModels.Connect.AddToRoster () =>
         ko.applyBindings vm, @
   $("#connect-profile-page").live "pagebeforeshow", () ->
      vm = new window.fannect.viewModels.Connect.Profile () =>
         ko.applyBindings vm, @
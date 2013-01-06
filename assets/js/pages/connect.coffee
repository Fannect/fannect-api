$(document).bind "mobileinit", () ->
   $("#connect-page").live "pagecreate", () ->
      vm = new window.fannect.viewModels.Connect () =>
         ko.applyBindings vm, @
   $("#connect-addToRoster-page").live "pagecreate", () ->
      vm = new window.fannect.viewModels.Connect.AddToRoster () =>
         ko.applyBindings vm, @
   $("#connect-profile-page").live "pagecreate", () ->
      vm = new window.fannect.viewModels.Connect.Profile () =>
         ko.applyBindings vm, @
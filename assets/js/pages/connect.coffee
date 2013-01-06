$(document).bind "mobileinit", () ->
   $("#connect-page").live "pagecreate", () ->
      new window.fannect.viewModels.Connect (err, vm) =>
         ko.applyBindings vm, @
   $("#connect-addToRoster-page").live "pagecreate", () ->
      new window.fannect.viewModels.Connect.AddToRoster (err, vm) =>
         ko.applyBindings vm, @
   $("#connect-profile-page").live "pagecreate", () ->
      new window.fannect.viewModels.Connect.Profile (err, vm) =>
         ko.applyBindings vm, @
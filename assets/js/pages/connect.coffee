$(document).bind "mobileinit", () ->
   $("#connect-page").live "pagecreate", () ->
      new window.fannect.viewModels.Connect (err, vm) =>
         ko.applyBindings vm, @
   $("#connect-addToRoster-page").live "pagecreate", () ->
      new window.fannect.viewModels.Connect.AddToRoster (err, vm) =>
         ko.applyBindings vm, @
   $("#connect-addToRosterProfile-page").live "pagecreate", () ->
      new window.fannect.viewModels.Connect.AddToRosterProfile (err, vm) =>
         ko.applyBindings vm, @
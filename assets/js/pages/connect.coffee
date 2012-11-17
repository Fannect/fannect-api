$(document).bind "mobileinit", () ->
   $(".connect-connect").live "pagebeforeshow", () ->
      ko.applyBindings new window.fannect.viewModels.Connect(window.fannect.connect), this
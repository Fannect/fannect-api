$(document).bind "mobileinit", () ->
   $(".connect").live "pagebeforeshow", () ->
      ko.applyBindings new window.fannect.viewModels.Connect(window.fannect.connect), this
$(document).bind "mobileinit", () ->
   $(".connect-connect").live "pagebeforeshow", () ->
      ko.applyBindings new window.fannect.viewModels.connect(window.fannect.connect), this
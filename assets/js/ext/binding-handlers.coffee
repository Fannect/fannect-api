do ($ = jQuery) ->
   ko.bindingHandlers.fadeIn = 
      update: (element, valueAccessor, allBindingAccessor, viewModel, bindingContext) ->
         valueUnwrapped = ko.utils.unwrapObservable valueAccessor()
         duration = allBindingAccessor().duration or 400
         if valueUnwrapped
            $(element).fadeIn duration
         else
            $(element).fadeOut duration

   ko.bindingHandlers.disableSlider = 
      update: (element, valueAccessor, allBindingAccessor, viewModel, bindingContext) ->
         valueUnwrapped = ko.utils.unwrapObservable valueAccessor()
         if valueUnwrapped
            $(element).slider "disable"
            # setTimeout (() -> $(element).slider "disable"), 300
         else
            $(element).slider "enable"

   ko.bindingHandlers.disableButton =
      update: (element, valueAccessor, allBindingAccessor, viewModel, bindingContext) ->
         valueUnwrapped = ko.utils.unwrapObservable valueAccessor()
         if valueUnwrapped
            $(element).button "disable"
         else
            $(element).button "enable"

   ko.bindingHandlers.listviewUpdate =
      update: (element, valueAccessor, allBindingAccessor, viewModel, bindingContext) ->
         ko.utils.unwrapObservable valueAccessor()
         $(element).listview "refresh"

   ko.bindingHandlers.sliderUpdate =
      update: (element, valueAccessor, allBindingAccessor, viewModel, bindingContext) ->
         ko.utils.unwrapObservable valueAccessor()
         $(element).slider "refresh"
do ($ = jQuery) ->
   ko.bindingHandlers.fadeIn = 
      update: (element, valueAccessor, allBindingAccessor, viewModel, bindingContext) ->
         valueUnwrapped = ko.utils.unwrapObservable valueAccessor()
         duration = allBindingAccessor().duration or 400
         if valueUnwrapped
            $(element).fadeIn duration
         else
            $(element).fadeOut duration
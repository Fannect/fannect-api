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
            setTimeout (() -> $(element).slider "disable"), 300
         else
            $(element).slider "enable"

   ko.bindingHandlers.disableButton =
      update: (element, valueAccessor, allBindingAccessor, viewModel, bindingContext) ->
         valueUnwrapped = ko.utils.unwrapObservable valueAccessor()
         if valueUnwrapped
            $(element).button "disable"
         else
            $(element).button "enable"

   ko.bindingHandlers.toggleClass =
      update: (element, valueAccessor, allBindingAccessor, viewModel, bindingContext) ->
         valueUnwrapped = ko.utils.unwrapObservable valueAccessor()
         $el = $(element)
         
         if valueUnwrapped
            for key, value of valueUnwrapped
               if value then $el.addClass key else $el.removeClass key

   ko.bindingHandlers.listviewUpdate =
      update: (element, valueAccessor, allBindingAccessor, viewModel, bindingContext) ->
         console.log element, ko.utils.unwrapObservable valueAccessor()
         $(element).listview "refresh"
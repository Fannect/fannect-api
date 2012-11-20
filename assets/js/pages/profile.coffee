do ($ = window.jQuery, ko = window.ko) ->
   $(document).bind "mobileinit", () ->
       $(".profile-profile").live "pagebeforeshow", () ->
         scroller = $(".points-guessTheScore-pick .scrolling-text").scroller()
         viewModel = new window.fannect.viewModels.GuessTheScore()
         ko.applyBindings viewModel, this
         scroller.scroller("start")

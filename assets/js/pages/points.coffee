do ($ = window.jQuery, ko = window.ko) ->
   showMenu = () ->
      window.fannect.setActiveMenu("points")

   setupGuessTheScore = () ->
      $(".points-guessTheScore-pick").live "pagebeforeshow", () ->
         showMenu()
         scroller = $(".points-guessTheScore-pick .scrolling-text").scroller()
         viewModel = new window.fannect.viewModels.guessTheScore()
         ko.applyBindings viewModel, this
         scroller.scroller("start")
      
      $(".points-guessTheScore-pick").live "pagebeforehide", () ->
         $(".points-guessTheScore-pick .scrolling-text").scroller()

   setupGameFace = () ->
      $()

   $(document).bind "mobileinit", () ->
      setupGuessTheScore()
      setupGameFace()


      # $(".points-gameFace-gameDay").live "pageinit", () ->
      #    $(".points-gameFace-gameDay #gameFaceSwitch").live "change", () ->
      #       $el = $(this)
      #       if  $el.val() == "on"
      #          $(".points-gameFace-gameDay .game-face").addClass("on")
      #       else
      #          $(".points-gameFace-gameDay .game-face").removeClass("on")

      # $(".points-gameFace-noGame").live("pagebeforeshow", () ->
      #    showMenu()
      #    $(".points-gameFace-noGame .scrolling-text").scroller()
      # ).live("pageshow", () ->
      #    $(".points-gameFace-noGame .scrolling-text").scroller("start")
      # ).live "pagebeforehide", () ->
      #    $(".points-gameFace-noGame .scrolling-text").scroller("stop")

      

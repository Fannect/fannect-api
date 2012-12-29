do ($ = window.jQuery, ko = window.ko) ->
   # teamScrollbar = null
   # nextBtn = null
   # prevBtn = null

   $(document).bind "mobileinit", () ->
      $(".profile").live("pagebeforeshow", () ->
         scroller = $(".points-guessTheScore-pick .scrolling-text").scroller()
         
         vm = new window.fannect.viewModels.Profile () =>
            ko.applyBindings vm, @
            scroller.scroller("start")
      )
      # ).live("pageshow", () ->    
      #    nextBtn = $(".profile .teams-wrap .button.next");
      #    prevBtn = $(".profile .teams-wrap .button.prev");

      #    teamScrollbar = new iScroll $(".profile .teams-wrap .view-port").get(0),
      #       snap: true
      #       momentum: false
      #       hScrollbar: false
      #       onScrollStart: () ->
      #          nextBtn.hide()
      #          prevBtn.hide()
      #       onScrollEnd: setTeamButtonVisiblity
               
      #    nextBtn.click () ->
      #       teamScrollbar.scrollToPage("next", 0)
      #       return false
      #    prevBtn.click () ->
      #       teamScrollbar.scrollToPage("prev", 0)
      #       return false

      #    setTeamButtonVisiblity()

      # ).live "pagebeforehide", () ->
      #    if teamScrollbar then teamScrollbar.destroy()

   # setTeamButtonVisiblity = () ->
   #    if teamScrollbar.currPageX == 0 then prevBtn.hide() else prevBtn.show()
   #    if teamScrollbar.currPageX == teamScrollbar.pagesX.length - 1 then nextBtn.hide() else nextBtn.show()
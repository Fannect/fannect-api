#= require "lib/jquery-1.8.2.js"
#= require "lib/knockout.js"
#= require_tree "pages"
#= require_tree "viewModels"
#= require "lib/jquerymobile-1.2.0.js"
#= require_tree "ext"

do ($ = window.jQuery) ->
   $(".ui-page").live "pagebeforeshow", () ->
      menu = $(this).children(".header").first().children("h1").attr("data-menu-root")
      if menu
         $(".footer .ui-btn-active").removeClass("ui-btn-active").removeClass("ui-btn-persist")
         $(".footer ." + menu + "-menu").addClass("ui-btn-active").addClass("ui-btn-persist")

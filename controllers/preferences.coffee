express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/preferences", (req, res, next) ->
   res.render "preferences/preferences"

app.get "/preferences/account", (req, res, next) ->
   res.render "preferences/account"

app.get "/preferences/support", (req, res, next) ->
   res.render "preferences/support"

app.get "/preferences/aboutFannect", (req, res, next) ->
   res.render "preferences/aboutFannect"

app.get "/preferences/aboutFullTiltVentures", (req, res, next) ->
   res.render "preferences/aboutFullTiltVentures"

app.get "/preferences/aboutRadeEccles", (req, res, next) ->
   res.render "preferences/aboutRadeEccles"

app.get "/preferences/privacy", (req, res, next) ->
   res.render "preferences/privacy"
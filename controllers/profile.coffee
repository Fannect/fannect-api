express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/profile", (req, res, next) ->
   res.render "profile/profile"

app.get "/profile/selectSport", (req, res, next) ->
   sports = [ "basketball", "football" ]
   res.render "profile/selectSport", sports: sports

app.get "/profile/selectLeague", (req, res, next) ->
   sport = req.query.sport
   leagues = [ "NFL", "NCAA" ]
   res.render "profile/selectLeague", leagues: leagues

app.get "/profile/selectTeam", (req, res, next) ->
   league = req.query.league
   teams = [ "Arizona Cardinals", "Chicago Bears" ]
   res.render "profile/selectTeam", teams: teams
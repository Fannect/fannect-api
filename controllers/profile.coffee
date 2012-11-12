express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/profile", (req, res, next) ->
   profileInfo = 
      user_image: ""
      team_image: ""
      data:
         roster: 0
         points: 0
         rank: 0
      name: "Jeremy Eccles"
      personal: 
         bio: "lots of stuff"
         game_day_spot: "more stuff"
         bragging_rights: "other stuff"

   res.render "profile/profile", profileInfo

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
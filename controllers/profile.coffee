express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/profile", (req, res, next) ->
   profileInfo = 
      user_image: "/dev/Pic_Player@2x.png"
      team_image: "/dev/Pic_Team@2x.png"
      score:
         roster: 0
         points: 0
         rank: 0
      name: "Jeremy Eccles"
      team: "Sporting Kansas City"
      personal: 
         bio: "Jeremy is the CEO and Vice President of Design of Rade | Eecles, one of the world's finest iOS application development companies. He is a fan of Sporting KC and the Ninja Dragons."
         game_day_spot: "Midfield in a folding chair at pitch number 6 in Tiffany Springs Park."
         bragging_rights: "His son's soccer team, the Ninja Dragons, won their division last season and are undefeated this season."

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
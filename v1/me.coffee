express = require "express"
rest = require "request"
sf = require "node-salesforce"

app = module.exports = express()

app.get "/", (req, res, next) -> 
   res.json [ "v1" ]

app.get "/v1/me", (req, res, next) ->
   res.json
      "profile_image": "http://res.cloudinary.com/fannect/image/upload/v1358008539/005E0000002ajXMIAY_Profile_Image.jpg",
      "team_image": null,
      "roster": 0,
      "points": 0,
      "rank": 0,
      "name": "Frank Enstein",
      "favorite_team": "Adams St. Cougars",
      "bio": "Go State!",
      "game_day_spot": "I like sports.",
      "bragging_rights": "Оружие хорошо"
      

app.use require "./me/games"
app.use require "./me/invites"
app.use require "./me/token"
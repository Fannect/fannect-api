express = require "express"
rest = require "request"
crypt = require "../utils/crypt"
mongoose = require "mongoose"
User = require "../models/User"

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
      
app.post "/v1/me", (req, res, next) ->
   if not body = req.body then next "Missing body"

   User.create
      email: body.email
      password: crypt.hashPassword body.password
      first_name: body.first_name
      last_name: body.last_name
      refresh_token: crypt.generateRefreshToken()
   , (err, user) ->
      if err then next err
      else res.json user

app.use require "./me/games"
app.use require "./me/invites"
app.use require "./me/token"
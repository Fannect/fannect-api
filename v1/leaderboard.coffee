express = require "express"
rest = require "request"
auth = require "../common/middleware/authenticate"
TeamProfile = require "../common/models/TeamProfile"
MongoError = require "../common/errors/MongoError"


app = module.exports = express()

app.get "/v1/leaderboard/users/:team_id", auth.rookie, (req, res, next) ->
   friends_only = req.query.friends_only

   TeamProfile
   .find({ "friends": friends_only })
   .sort("points")
   .select("profile_image_url name")
   .exec (err, done) ->
      return next(new MongoError(err)) if err


app.get "/v1/leaderboard/:team_id", auth.rookie, (req, res, next) ->
   count = req.query.count
   skip = req.query.skip

   fans = 
      [
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "leaderboard-rosterprofile.html"
            profile_image_url: "http://fannect.herokuapp.com/dev/Pic_Player@2x.png"
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "leaderboard-rosterprofile.html"
            profile_image_url: "http://fannect.herokuapp.com/dev/Pic_Player@2x.png"
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "leaderboard-rosterprofile.html"
            profile_image_url: "http://fannect.herokuapp.com/dev/Pic_Player@2x.png"
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "leaderboard-rosterprofile.html"
            profile_image_url: "http://fannect.herokuapp.com/dev/Pic_Player@2x.png"
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "leaderboard-rosterprofile.html"
            profile_image_url: "http://fannect.herokuapp.com/dev/Pic_Player@2x.png"
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "leaderboard-rosterprofile.html"
            profile_image_url: "http://fannect.herokuapp.com/dev/Pic_Player@2x.png"
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "leaderboard-rosterprofile.html"
            profile_image_url: "http://fannect.herokuapp.com/dev/Pic_Player@2x.png"
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "leaderboard-rosterprofile.html"
            profile_image_url: "http://fannect.herokuapp.com/dev/Pic_Player@2x.png"
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "leaderboard-rosterprofile.html"
            profile_image_url: "http://fannect.herokuapp.com/dev/Pic_Player@2x.png"
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "leaderboard-rosterprofile.html"
            profile_image_url: "http://fannect.herokuapp.com/dev/Pic_Player@2x.png"
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "leaderboard-rosterprofile.html"
            profile_image_url: "http://fannect.herokuapp.com/dev/Pic_Player@2x.png"
            rank: 1
         }
      ]

   res.json fans
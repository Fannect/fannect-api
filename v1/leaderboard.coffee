express = require "express"
rest = require "request"
authenticate = require "../common/middleware/authenticate"

app = module.exports = express()

app.get "/v1/leaderboard/:team_id", authenticate, (req, res, next) ->
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
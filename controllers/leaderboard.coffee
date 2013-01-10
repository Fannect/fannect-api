express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/api/leaderboard", (req, res, next) ->
   overall_fans = roster_fans = 
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

   if req.query.type == "overall" then return res.json fans: overall_fans
   else res.json fans: roster_fans
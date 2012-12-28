express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/leaderboard", (req, res, next) ->
   overall_fans = roster_fans = 
      [
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: ""
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: ""
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: ""
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
             name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: ""
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
             name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: ""
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
             name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: ""
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: ""
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         }
      ]

   if req.query.type == "overall" then return res.json fans: overall_fans
   else res.json fans: roster_fans
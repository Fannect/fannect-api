express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/connect", (req, res, next) ->
   roster_fans = 
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

   res.render "connect/connect", fans: roster_fans
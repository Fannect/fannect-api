express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/connect", (req, res, next) ->
   roster_fans = 
      [
         # {
         #    name: "Jeremy Eccles"
         #    team: "Sporting Kansas City"
         #    profile_url: ""
         #    profile_image_url: "/dev/Pic_Player@2x.png"
         #    roster: 100
         #    points: 100
         #    rank: 1
         # },
         # {
         #    name: "Jeremy Eccles"
         #    team: "Sporting Kansas City"
         #    profile_url: ""
         #    profile_image_url: "/dev/Pic_Player@2x.png"
         #    roster: 100
         #    points: 100
         #    rank: 1
         # },
         # {
         #    name: "Jeremy Eccles"
         #    team: "Sporting Kansas City"
         #    profile_url: ""
         #    profile_image_url: "/dev/Pic_Player@2x.png"
         #    roster: 100
         #    points: 100
         #    rank: 1
         # },
         # {
         #     name: "Jeremy Eccles"
         #    team: "Sporting Kansas City"
         #    profile_url: ""
         #    profile_image_url: "/dev/Pic_Player@2x.png"
         #    roster: 100
         #    points: 100
         #    rank: 1
         # },
         # {
         #     name: "Jeremy Eccles"
         #    team: "Sporting Kansas City"
         #    profile_url: ""
         #    profile_image_url: "/dev/Pic_Player@2x.png"
         #    roster: 100
         #    points: 100
         #    rank: 1
         # },
         # {
         #     name: "Jeremy Eccles"
         #    team: "Sporting Kansas City"
         #    profile_url: ""
         #    profile_image_url: "/dev/Pic_Player@2x.png"
         #    roster: 100
         #    points: 100
         #    rank: 1
         # },
         # {
         #    name: "Jeremy Eccles"
         #    team: "Sporting Kansas City"
         #    profile_url: ""
         #    profile_image_url: "/dev/Pic_Player@2x.png"
         #    roster: 100
         #    points: 100
         #    rank: 1
         # }
      ]

   res.json fans: roster_fans

app.get "/connect/addToRoster", (req, res, next) ->
   roster_fans = 
      [
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-profile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-profile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-profile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-profile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-profile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-profile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-profile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-profile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-profile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-profile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-profile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-profile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         }
      ]

   res.json fans: roster_fans
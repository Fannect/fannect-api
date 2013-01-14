express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/me/connect", (req, res, next) ->

   count = req.query.count
   skip = req.query.skip

   # conn = req.conn
   # conn.query "SELECT Id FROM User WHERE Id = 005E0000001jeZ4IAI", (err, data) ->
   #    return res.json data
   # conn.sobject("Roster__c")
   #    .find({
   #       "FanName__c": req.session.user_id
   #    }, {
   #       "Teammate__r.Name": 1
   #    })
   #    .execute (err, roster) ->
   #       if err then res.json err else res.json roster


# app.get "/fans", (req, res, next) ->
   roster_fans = 
      [
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-addToRosterProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-addToRosterProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-addToRosterProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-addToRosterProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-addToRosterProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-addToRosterProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-addToRosterProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-addToRosterProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-addToRosterProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "connect-addToRosterProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         }
      ]

   res.json roster_fans
express = require "express"
rest = require "request"
auth = require "../common/middleware/authenticate"
TeamProfile = require "../common/models/TeamProfile"
Team = require "../common/models/Team"
MongoError = require "../common/errors/MongoError"

app = module.exports = express()

app.post "/v1/users/invite", auth.rookie, (req, res, next) ->
   other_id = req.body.user_id

   User
   .update { _id: other_id }, { $addToSet: { invites: req.user._id } }, (err, row, raw) ->
      return next(new MongoError(err)) if err

      console.log "raw", raw
      res.json status: "success"

app.get "/v1/users", auth.rookie, (req, res, next) ->
   count = req.query.count
   skip = req.query.skip
   q = req.query.q

   # FINISH
   if q
      regex = if q then new RegExp("(|.*[\s]+)(#{q}).*", "i")
      TeamProfile
      .find({ name: regex })
      .sort("name")
      .select("profile_image_url name")
   else
      TeamProfile
      .find({ friends: req.user._id })
      .sort("name")
      .select("profile_image_url name")


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
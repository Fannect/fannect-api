express = require "express"
rest = require "request"
auth = require "../common/middleware/authenticate"
TeamProfile = require "../common/models/TeamProfile"
MongoError = require "../common/errors/MongoError"


app = module.exports = express()

app.get "/v1/leaderboard/users/:team_id", auth.rookie, (req, res, next) ->
   friends_of = req.query.friends_of
   team_id = req.params.team_id

   if friends_of
      TeamProfile
      .find({ "team_id": team_id, $or: [{"friends": friends_of}, {"_id": friends_of}]})
      .sort("-points.overall")
      .select("profile_image_url name points")
      .exec (err, profiles) ->
         return next(new MongoError(err)) if err
         res.json profiles
   else
      TeamProfile
      .find({ "team_id": team_id })
      .sort("-points.overall")
      .select("profile_image_url name points")
      .exec (err, profiles) ->
         return next(new MongoError(err)) if err
         res.json profiles

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
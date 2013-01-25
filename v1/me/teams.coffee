express = require "express"
auth = require "../../common/middleware/authenticate"
TeamProfile = require "../../common/models/TeamProfile"
Team = require "../../common/models/Team"
MongoError = require "../../common/errors/MongoError"

app = module.exports = express()

# Get team profiles
app.get "/v1/me/teams", auth.rookie, (req, res, next) ->
   TeamProfile
   .find({ user_id: req.user._id })
   .select("team_id team_name team_key points trash_talk.0")
   .exec (err, team_profiles) ->
      return next(new MongoError(err)) if err
      res.json team_profiles

# Add team profile
app.post "/v1/me/teams", auth.rookie, (req, res, next) ->
   team_id = req.body.team_id

   TeamProfile.createAndAttach req.user, team_id, (err, teamProfile) ->
      return next(err) if err
      res.json teamProfile



app.get "/v1/me/teams/:team_profile_id", auth.rookie, (req, res, next) ->
   
   teams = [
      {
         user_id: "blahblah"
         team_profile_id: "12345"
         name: "Kansas State Wildcats"
         team_image_url: "" 
         team_id: "something"
         roster: 0
         points: 0
         rank: 0
      },
      {
         user_id: "blahblah"
         team_profile_id: "54321"
         name: "Kansas City Chiefs"
         team_image_url: "" 
         team_id: "something"
         roster: 0
         points: 0
         rank: 0
      }
   ]

   res.json teams[req.params.team_profile_id]

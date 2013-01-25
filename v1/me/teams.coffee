express = require "express"
auth = require "../../common/middleware/authenticate"
TeamProfile = require "../../common/models/TeamProfile"
Team = require "../../common/models/Team"
MongoError = require "../../common/errors/MongoError"
ResourceNotFoundError = require "../../common/errors/ResourceNotFoundError"

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

# Get single team profile by id
app.get "/v1/me/teams/:team_profile_id", auth.rookie, (req, res, next) ->
   TeamProfile.findById req.params.team_profile_id, (err, profile) ->
      return next(new MongoError(err)) if err
      return next(new ResourceNotFoundError()) unless profile
      res.json profile

app.put "/v1/me/teams/:team_profile_id", auth.rookie, (req, res, next) ->
   
express = require "express"
auth = require "../../common/middleware/authenticate"
TeamProfile = require "../../common/models/TeamProfile"
Team = require "../../common/models/Team"
MongoError = require "../../common/errors/MongoError"
ResourceNotFoundError = require "../../common/errors/ResourceNotFoundError"
InvalidArgumentError = require "../../common/errors/InvalidArgumentError"

app = module.exports = express()

# Get team profiles
app.get "/v1/me/teams", auth.rookieStatus, (req, res, next) ->
   TeamProfile
   .find({ user_id: req.user._id })
   .select("team_id team_name team_key points trash_talk.0")
   .exec (err, team_profiles) ->
      return next(new MongoError(err)) if err
      res.json team_profiles

# Add team profile
app.post "/v1/me/teams", auth.rookieStatus, (req, res, next) ->
   team_id = req.body.team_id
   next(new InvalidArgumentError("Required: team_id")) unless team_id

   TeamProfile.createAndAttach req.user, team_id, (err, teamProfile) ->
      return next(err) if err
      p = teamProfile.toObject()

      delete p.events
      delete p.wating_events
      delete p.has_processing
      delete p.friends
      delete p.__v

      res.json teamProfile

# Get single team profile by id
app.get "/v1/me/teams/:team_profile_id", auth.rookieStatus, (req, res, next) ->
   TeamProfile.findById req.params.team_profile_id, 
      "name profile_image_url team_id team_image_url team_key team_name user_id points"
   , (err, profile) ->
      return next(new MongoError(err)) if err
      return next(new ResourceNotFoundError()) unless profile
      res.json profile

app.put "/v1/me/teams/:team_profile_id", auth.rookieStatus, (req, res, next) ->
   
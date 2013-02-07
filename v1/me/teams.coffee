mongoose = require "mongoose"
express = require "express"
auth = require "../../common/middleware/authenticate"
TeamProfile = require "../../common/models/TeamProfile"
Team = require "../../common/models/Team"
MongoError = require "../../common/errors/MongoError"
ResourceNotFoundError = require "../../common/errors/ResourceNotFoundError"
InvalidArgumentError = require "../../common/errors/InvalidArgumentError"
async = require "async"
User = require "../../common/models/User"
twitter = require "../../common/utils/twitterReq"

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
      { user_id: 1, name: 1, profile_image_url: 1, team_id: 1, team_image_url: 1, team_name: 1, points: 1, shouts: { $slice: [-1, 1]}, is_college: 1 }
   , (err, profile) ->
      return next(new MongoError(err)) if err
      return next(new ResourceNotFoundError()) unless profile
      res.json profile
         
deleteTeamProfile = (req, res, next) ->
   profile_id = req.params.team_profile_id
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"

   TeamProfile
   .findById profile_id, "user_id", (err, profile) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"
      
      async.parallel
         profile: (done) -> profile.remove(done)
         otherProfiles: (done) ->
            TeamProfile
            .update({ friends: profile_id }, { $pull: { friends: profile_id }}, done)
         user: (done) ->
            User
            .update({ _id: profile.user_id }, { $pull: { team_profiles: profile_id }}, done)
      , (err) ->
         return next(new MongoError(err)) if err
         res.json status: "success"
   
app.del "/v1/me/teams/:team_profile_id", auth.rookieStatus, deleteTeamProfile
app.post "/v1/me/teams/:team_profile_id/delete", auth.rookieStatus, deleteTeamProfile

app.post "/v1/me/teams/:team_profile_id/shouts", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   shout = req.body.shout
   next(new InvalidArgumentError("Required: shout")) unless shout
   next(new InvalidArgumentError("Invalid: shout should be 140 characters or less")) if shout.length > 140
   tweet = req.body.tweet or false

   saveShout = (cb) ->
      TeamProfile
      .update({_id: profile_id}, { $push: { shouts: { _id: new mongoose.Types.ObjectId, text: shout } } })
      .exec cb

   resp = (err, data) ->
      return next(new MongoError(err)) if err
      res.json status: "success"
   
   if tweet
      async.parallel
         shout: saveShout
         tweet: (done) -> twitter.tweet(req.query.access_token, req.user.twitter, shout, done)
      , resp
   else
      saveShout(resp)

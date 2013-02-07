express = require "express"
rest = require "request"
mongoose = require "mongoose"
User = require "../common/models/User"
TeamProfile = require "../common/models/TeamProfile"
auth = require "../common/middleware/authenticate"
redis = require("../common/utils/redis").client
MongoError = require "../common/errors/MongoError"
async = require "async"

app = module.exports = express()

# Get this user
app.get "/v1/me", auth.rookieStatus, (req, res, next) ->
   User.findById req.user._id, "email profile_image_url first_name last_name invites twitter"
   , (err, user) ->
      return next(new MongoError(err)) if err

      user = user.toObject()

      # Set if user has connected twitter
      user.twitter = if user.twitter?.user_id then true else false
      res.json user

updateProfile = (req, res, next) ->
   b = req.body
   
   data = {}
   data.first_name = b.first_name if b.first_name
   data.last_name = b.last_name if b.last_name

   async.parallel [
      (done) -> User.update { _id: req.user._id }, data, done
      (done) ->
         # Update name in all TeamProfiles
         if b.first_name or b.last_name
            name = "#{b.first_name or req.user.first_name} #{b.last_name or req.user.last_name}"
            TeamProfile.update { user_id: req.user._id },
               { name: name },
               { multi: true } 
            , done
   ], (err, data) ->
      return next(new MongoError(err)) if err
      res.json status: "success"

# Update this user
app.post "/v1/me/update", auth.rookieStatus, updateProfile
app.put "/v1/me", auth.rookieStatus, updateProfile

updatePush = (req, res, next) ->
   updates = push: {}
   updates["push"]["game_notice"] = req.body.game_notice if req.body.game_notice
   updates["push"]["points_notice"] = req.body.point_notice if req.body.point_notice

   User.update { _id: req.user._id }, updates, (err) ->
      return next(new MongoError(err)) if err
      res.json status: "success"

app.post "/v1/me/push/update", auth.rookieStatus, updatePush
app.put "/v1/me/push", auth.rookieStatus, updatePush

app.use require "./me/games"
app.use require "./me/invites"
app.use require "./me/teams"
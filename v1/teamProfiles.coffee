express = require "express"
rest = require "request"
auth = require "../common/middleware/authenticate"
TeamProfile = require "../common/models/TeamProfile"
MongoError = require "../common/errors/MongoError"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"

app = module.exports = express()

app.get "/v1/teamprofiles/:team_profile_id", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   is_friend_of = req.query.is_friend_of

   TeamProfile
   .findOne({ _id: profile_id })
   .select("team_id user_id name points friends team_image_url profile_image_url")
   .lean()
   .exec (err, profile) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: team_profile_id")) unless profile
      if is_friend_of then profile.is_friend = (is_friend_of in profile.friends)
      delete profile.friends

      res.json profile
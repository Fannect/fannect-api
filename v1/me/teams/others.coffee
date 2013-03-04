# express = require "express"
# rest = require "request"
# auth = require "../common/middleware/authenticate"
# TeamProfile = require "../common/models/TeamProfile"
# User = require "../common/models/User"
# MongoError = require "../common/errors/MongoError"
# InvalidArgumentError = require "../common/errors/InvalidArgumentError"
# async = require "async"

# app = module.exports = express()

# app.get "/v1/teams/:team_profile_id/others/:other_profile_id", auth.rookieStatus, (req, res, next) ->
#    profile_id = req.params.team_profile_id
#    other_id = req.params.other_profile_id
   
#    return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"

#    TeamProfile
#    .findOne({ _id: profile_id })
#    .select({ user_id: 1, name: 1, profile_image_url: 1, team_id: 1, team_image_url: 1, team_name: 1, points: 1, shouts: { $slice: [-1, 1]}, is_college: 1, friends: 1, friends_count: 1, rank: 1, verified:1 })
#    .lean()
#    .exec (err, profile) ->
#       return next(new MongoError(err)) if err
#       return next(new InvalidArgumentError("Invalid: other_profile_id")) unless profile
      
#       profile.is_friend = false
#       profile.is_invited = false
#       for id in profile.friends
#          if team_profile_id == id.toString()
#             profile.is_friend = true
#             break
      
#       delete profile.friends
#       return res.json(profile) if profile.is_friend

#       for id in req.user.invites
#          if profile.user_id.toString() == id.toString()
#             profile.has_invited = true
#             break

#       res.json profile


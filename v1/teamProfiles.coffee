express = require "express"
rest = require "request"
auth = require "../common/middleware/authenticate"
TeamProfile = require "../common/models/TeamProfile"
MongoError = require "../common/errors/MongoError"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"

app = module.exports = express()

app.get "/v1/teamprofiles", auth.rookieStatus, (req, res, next) ->
   friends_with = req.query.friends_with
   user_id = req.query.user_id
   return next(new InvalidArgumentError("Required: friends_with")) unless friends_with

   TeamProfile
   .findById(friends_with)
   .select("team_id user_id")
   .lean()
   .exec (err, friend) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: friends_with")) unless friend

      TeamProfile
      .findOne({ user_id: user_id, team_id: friend.team_id })
      .select({ user_id: 1, name: 1, profile_image_url: 1, team_id: 1, team_image_url: 1, team_name: 1, points: 1, shouts: { $slice: [-1, 1]}, is_college: 1 })
      .lean()
      .exec (err, profile) ->

         return next(new MongoError(err)) if err
         return res.json profile if profile

         # possible team ids
         TeamProfile
         .find({ user_id: friend.user_id })
         .select({ _id: 0, team_id: 1 })
         .lean()
         .exec (err, teams) ->
            return next(new MongoError(err)) if err

            TeamProfile
            .findOne({ user_id: user_id, team_id: { $in: (t.team_id for t in teams) }})
            .select({ user_id: 1, name: 1, profile_image_url: 1, team_id: 1, team_image_url: 1, team_name: 1, points: 1, shouts: { $slice: [-1, 1]}, is_college: 1 })
            .lean()
            .exec (err, profile) ->
               return next(new MongoError(err)) if err
               res.json profile if profile

app.get "/v1/teamprofiles/:team_profile_id", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   is_friend_of = req.query.is_friend_of

   TeamProfile
   .findOne({ _id: profile_id })
   .select({ user_id: 1, name: 1, profile_image_url: 1, team_id: 1, team_image_url: 1, friends: 1, team_name: 1, points: 1, shouts: { $slice: [-1, 1]}, is_college: 1 })
   .lean()
   .exec (err, profile) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: team_profile_id")) unless profile
      
      if is_friend_of
         profile.is_friend = false
         for id in profile.friends
            if is_friend_of == id.toString()
               profile.is_friend = true
               break

      delete profile.friends

      res.json profile
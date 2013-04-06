express = require "express"
rest = require "request"
auth = require "../common/middleware/authenticate"
TeamProfile = require "../common/models/TeamProfile"
Highlight = require "../common/models/Highlight"
User = require "../common/models/User"
MongoError = require "../common/errors/MongoError"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"
async = require "async"

app = module.exports = express()

app.get "/v1/teamprofiles", auth.rookieStatus, (req, res, next) ->
   friends_with = req.query.friends_with
   user_id = req.query.user_id
   return next(new InvalidArgumentError("Required: friends_with")) unless friends_with

   TeamProfile
   .findOne({ _id: friends_with, is_active: true })
   .select("team_id user_id")
   .lean()
   .exec (err, friend) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: friends_with")) unless friend

      TeamProfile
      .findOne({ user_id: user_id, team_id: friend.team_id, is_active: true })
      .select({ user_id: 1, name: 1, profile_image_url: 1, team_id: 1, team_image_url: 1, team_name: 1, points: 1, shouts: { $slice: [-1, 1]}, is_college: 1, friends_count: 1, rank: 1, verified:1 })
      .lean()
      .exec (err, profile) ->

         return next(new MongoError(err)) if err
         return res.json profile if profile

         # possible team ids
         TeamProfile
         .find({ user_id: friend.user_id, is_active: true })
         .select({ _id: 0, team_id: 1 })
         .lean()
         .exec (err, teams) ->
            return next(new MongoError(err)) if err

            TeamProfile
            .findOne({ user_id: user_id, is_active: true, team_id: { $in: (t.team_id for t in teams) }})
            .select({ user_id: 1, name: 1, profile_image_url: 1, team_id: 1, team_image_url: 1, team_name: 1, points: 1, shouts: { $slice: [-1, 1]}, is_college: 1, friends_count: 1, rank: 1, verified:1 })
            .lean()
            .exec (err, profile) ->
               return next(new MongoError(err)) if err
               res.json profile if profile

app.get "/v1/teamprofiles/:team_profile_id", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   is_friend_of = req.query.is_friend_of

   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"

   TeamProfile
   .findOne({ _id: profile_id, is_active: true })
   .select({ user_id: 1, name: 1, profile_image_url: 1, team_id: 1, team_image_url: 1, team_name: 1, points: 1, shouts: { $slice: [-1, 1]}, is_college: 1, friends: 1, friends_count: 1, rank: 1, verified:1 })
   .lean()
   .exec (err, profile) ->
      return next(new MongoError(err)) if err
      return next(new ResourceNotFoundError("Not found: TeamProfile")) unless profile
      
      if is_friend_of
         profile.is_friend = false
         for id in profile.friends
            if is_friend_of == id.toString()
               profile.is_friend = true
               break

      delete profile.friends

      res.json profile

app.get "/v1/teamprofiles/:team_profile_id/events", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   limit = req.query.limit or 20
   limit = parseInt(limit)
   limit = if limit > 20 then 20 else limit
   skip = req.query.skip or 0
   skip = parseInt(skip)
   
   if skip == 0
      slice = limit * -1
   else
      slice = [ skip * -1 - limit, limit ] 
   
   TeamProfile
   .findOne({ _id: profile_id, is_active: true })
   .select({ events: { $slice: slice } })
   .exec (err, profile) ->
      return next(new MongoError(err)) if err
      return next(new ResourceNotFoundError("Not found: TeamProfile")) unless profile
      events = profile.events or []
      res.json events.reverse()


app.get "/v1/teamprofiles/:team_profile_id/highlights", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   limit = req.query.limit or 20
   limit = parseInt(limit)
   limit = if limit > 20 then 20 else limit
   skip = req.query.skip or 0
   skip = parseInt(skip)
   
   Highlight
   .find({ owner_id: profile_id })
   .skip(skip)
   .limit(limit)
   .sort("-_id")
   .select({ _id:1, owner_user_id:1, owner_profile_image_url:1, short_id:1, image_url:1, caption:1, comment_count:1, comments:{$slice:limit}, up_votes:1, down_votes:1 })
   .exec (err, highlights) ->
      return next(new MongoError(err)) if err
      res.json highlights

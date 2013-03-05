mongoose = require "mongoose"
express = require "express"
auth = require "../common/middleware/authenticate"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"
RestError = require "../common/errors/RestError"
MongoError = require "../common/errors/MongoError"
User = require "../common/models/User"
Team = require "../common/models/Team"
TeamProfile = require "../common/models/TeamProfile"
Huddle = require "../common/models/Huddle"
async = require "async"

app = module.exports = express()

app.get "/v1/huddles/:huddle_id", auth.rookieStatus, (req, res, next) ->
   huddle_id = req.params.huddle_id
   return next(new InvalidArgumentError("Invalid: huddle_id")) if huddle_id == "undefined"

   Huddle
   .findOne({ _id: huddle_id })
   .select(_id:1,owner_user_id:1, owner_name:1, owner_verified:1, topic:1, 
      reply_count:1, replies:{$slice:5}, team_id:1, team_name:1, rating:1, 
      rating_count:1, last_reply_time:1, tags:1)
   .exec (err, huddle) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: huddle_id")) unless huddle
      res.json huddle

app.get "/v1/huddles/:huddle_id/replies", auth.rookieStatus, (req, res, next) ->
   huddle_id = req.params.huddle_id
   limit = req.query.limit or 10
   limit = parseInt(limit)
   limit = if limit > 20 then 20 else limit
   skip = req.query.skip or 0
   skip = parseInt(skip)
   reverse = req.query.reverse or false

   return next(new InvalidArgumentError("Invalid: huddle_id")) if huddle_id == "undefined"

   if skip == 0
      slice = if reverse then limit * -1 else limit
   else
      start = if reverse then skip * -1 - limit else skip
      slice = [ start, limit ] 

   Huddle
   .findById(huddle_id)
   .select({ replies: { $slice: slice } })
   .exec (err, huddle) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: huddle_id")) unless huddle
      replies = huddle.replies or []
      replies = replies.reverse() if reverse
      res.json replies
      
app.post "/v1/huddles/:huddle_id/replies", auth.rookieStatus, (req, res, next) ->
   huddle_id = req.params.huddle_id
   content = req.body.content
   profile_id = req.body.team_profile_id

   return next(new InvalidArgumentError("Invalid: huddle_id")) if huddle_id == "undefined"
   return next(new InvalidArgumentError("Require: team_profile_id")) unless profile_id
   return next(new InvalidArgumentError("Require: content")) unless content

   async.parallel
      huddle: (done) -> 
         Huddle.findById huddle_id, "reply_count team_id tags", done
      profile: (done) -> 
         TeamProfile.findById profile_id, "name user_id team_id team_name conference_key league_key verified", done
   , (err, results) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: huddle_id")) unless results.huddle
      return next(new InvalidArgumentError("Invalid: team_profile_id")) unless results.profile
   
      # Verify that the user is part of this huddle
      if results.huddle.team_id.toString() != results.profile.team_id.toString()
         valid = false
         for tag in results.huddle.tags
            if (tag.type == "conference" and tag.include_key == results.profile.conference_key or \
            tag.type == "league" and tag.include_key == results.profile.conference_key or \
            tag.type == "team" and tag.include_id == results.profile.team_id)
               valid = true
               break
         unless valid
            return next(new InvalidArgumentError("Invalid: team_profile_id, not part of this huddle")) 

      # Add to replies
      Huddle.update { _id: results.huddle._id },
         $push: 
            replies: 
               _id: mongoose.Types.ObjectId
               owner_id: results.profile._id
               owner_user_id: results.profile.user_id
               owner_name: results.profile.name
               owner_verified: results.profile.verified
               team_id: results.profile.team_id
               team_name: results.profile.team_name
               content: content  
         reply_count: results.huddle.reply_count + 1
         last_reply_time: new Date()
      , (err) ->
         return next(new MongoError(err)) if err
         res.json status: "success" 

app.post "/v1/huddles/:huddle_id/rating", auth.rookieStatus, (req, res, next) ->
   huddle_id = req.params.huddle_id
   profile_id = req.body.team_profile_id
   rating = req.body.rating or 0
   rating = parseInt(rating)

   return next(new InvalidArgumentError("Required: team_profile_id")) unless profile_id
   return next(new InvalidArgumentError("Required: rating")) unless rating
   return next(new InvalidArgumentError("Invalid: huddle_id")) if huddle_id == "undefined"
   return next(new InvalidArgumentError("Invalid: rating, must be between 1 and 5")) if rating < 1 or rating > 5
   
   Huddle
   .findOne({ _id: huddle_id, rated_by: {$ne: profile_id } })
   .select("rating rating_count")
   .exec (err, huddle) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: huddle_id or team profile has already rated")) unless huddle
      rating_sum = huddle.rating * huddle.rating_count + rating
      huddle.rating_count += 1
      huddle.rating = rating_sum / huddle.rating_count
      huddle.save (err) ->
         return next(new MongoError(err)) if err
         res.json
            status: "success"
            rating: huddle.rating
            rating_count: huddle.rating_count

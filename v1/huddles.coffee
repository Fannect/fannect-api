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
   limit = req.query.limit or 10
   limit = parseInt(limit)
   limit = if limit > 20 then 20 else limit
   return next(new InvalidArgumentError("Invalid: huddle_id")) if huddle_id == "undefined" or huddle_id == "null"

   Huddle
   .findOne({ _id: huddle_id })
   .select({ _id:1, owner_user_id:1, owner_name:1, owner_verified:1, topic:1, reply_count:1, replies:{$slice:limit}, team_id:1, team_name:1, rating:1, rating_count:1, last_reply_time:1, tags:1, views:1 })
   .exec (err, huddle) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: huddle_id")) unless huddle
      huddle.views++ unless huddle.owner_user_id.toString() == req.user._id.toString()
      
      obj = huddle.toObject()
      setReplyVoting(req.user._id, reply) for reply in obj.replies
      res.json obj
      
      # Update views
      huddle.save (err) ->
         console.error "Failed to update view count!", err if err

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
   .select({ replies: { $slice: slice }, reply_count: 1 })
   .lean()
   .exec (err, huddle) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: huddle_id")) unless huddle
      replies = huddle.replies or []
      replies = replies.reverse() if reverse
      setReplyVoting(req.user._id, reply) for reply in replies

      res.json
         meta: 
            skip: skip
            limit: limit
            reverse: reverse
            count: huddle.reply_count
         replies: replies

app.post "/v1/huddles/:huddle_id/replies", auth.rookieStatus, (req, res, next) ->
   huddle_id = req.params.huddle_id
   content = req.body.content
   profile_id = req.body.team_profile_id
   image_url = req.body.image_url
   image_url = null if image_url == "undefined" or image_url == "null"

   return next(new InvalidArgumentError("Invalid: huddle_id")) if huddle_id == "undefined"
   return next(new InvalidArgumentError("Require: team_profile_id")) unless profile_id
   return next(new InvalidArgumentError("Require: content")) unless content

   async.parallel
      huddle: (done) -> 
         Huddle.findById huddle_id, "reply_count team_id tags", done
      profile: (done) -> 
         TeamProfile.findById profile_id, "name user_id team_id team_name conference_key league_key verified profile_image_url", done
   , (err, results) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: huddle_id")) unless results.huddle
      return next(new InvalidArgumentError("Invalid: team_profile_id")) unless results.profile
   
      Team.findById results.profile.team_id, "conference_key league_key", (err, team) ->
         return next(new MongoError(err)) if err

         # Verify that the user is part of this huddle
         if results.huddle.team_id.toString() != results.profile.team_id.toString()
            valid = false
            for tag in results.huddle.tags
               if (tag.type == "conference" and tag.include_key == team.conference_key or \
               tag.type == "league" and tag.include_key == team.league_key or \
               tag.type == "team" and tag.include_id == results.profile.team_id)
                  valid = true
                  break
            unless valid
               return next(new InvalidArgumentError("Invalid: team_profile_id, not part of this huddle")) 

         reply = 
            _id: new mongoose.Types.ObjectId
            owner_id: results.profile._id
            owner_user_id: results.profile.user_id
            owner_name: results.profile.name
            owner_verified: results.profile.verified
            owner_profile_image_url: results.profile.profile_image_url
            team_id: results.profile.team_id
            team_name: results.profile.team_name
            content: content  
            up_votes: 0
            down_votes: 0
            image_url: image_url

         # Add to replies
         Huddle.update { _id: results.huddle._id },
            $push: { replies: reply }
            reply_count: results.huddle.reply_count + 1
            last_reply_time: new Date()
         , (err, result) ->
            return next(new MongoError(err)) if err
            return next(new RestError("Failed to save reply")) unless result == 1
            res.json 
               meta: { count: results.huddle.reply_count + 1 }
               reply: setReplyVoting(req.user._id, reply)

app.post "/v1/huddles/:huddle_id/replies/:reply_id/vote", auth.rookieStatus, (req, res, next) ->
   huddle_id = req.params.huddle_id
   reply_id = req.params.reply_id
   vote = req.body.vote

   return next(new InvalidArgumentError("Required: vote")) unless vote
   return next(new InvalidArgumentError("Invalid: vote must be 'up' or 'down'")) unless (vote == "up" or vote == "down")
   
   vote = if vote == "up" then "replies.$.up_votes" else "replies.$.down_votes"
   update = { $addToSet: { "replies.$.voted_by": req.user._id } }
   update["$inc"] = {}
   update["$inc"][vote] = 1

   Huddle
   .update { _id: huddle_id, replies: { $elemMatch: { _id: reply_id, owner_user_id: { $ne: req.user._id }, voted_by: { $ne: req.user._id } }}}
   , update
   , (err, result) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: arguments or user has already voted")) if result == 0
      res.json { status: "success" }

setReplyVoting = (user_id, reply) ->
   if user_id.toString() == reply.owner_user_id.toString()
      reply.is_owner = true
      reply.has_voted = true
   else
      reply.is_owner = false
      if reply?.voted_by 
         for v in reply.voted_by
            if user_id == v.toString() 
               reply.has_voted = true
               break
      else reply.has_voted = false

   delete reply.voted_by
   return reply

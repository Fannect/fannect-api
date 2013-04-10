mongoose = require "mongoose"
express = require "express"
auth = require "../common/middleware/authenticate"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"
ResourceNotFoundError = require "../common/errors/ResourceNotFoundError"
RestError = require "../common/errors/RestError"
MongoError = require "../common/errors/MongoError"
User = require "../common/models/User"
Team = require "../common/models/Team"
TeamProfile = require "../common/models/TeamProfile"
Highlight = require "../common/models/Highlight"
async = require "async"
twitterReq = require "../common/utils/twitterReq"

app = module.exports = express()

app.get "/v1/highlights/:highlight_id", auth.either("rookie", "manager"), (req, res, next) ->
   highlight_id = req.params.highlight_id
   limit = req.query.limit or 10
   limit = parseInt(limit)
   limit = if limit > 20 then 20 else limit
   return next(new InvalidArgumentError("Invalid: highlight_id")) if highlight_id == "undefined" or highlight_id == "null"

   if highlight_id.length == 24 then query = Highlight.findOne({ _id: highlight_id })
   else query = Highlight.findOne({ short_id: highlight_id })

   query
   .select({ _id:1, owner_user_id:1, owner_name:1, owner_profile_image_url:1, owner_verified:1, short_id:1, image_url:1, caption:1, comment_count:1, comments:{$slice:limit}, team_id:1, team_name:1, up_votes:1, up_voted_by:1, down_votes:1, down_voted_by:1 })
   .exec (err, highlight) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: highlight_id")) unless highlight
      
      obj = highlight.toObject()
      user_id = req.user?._id?.toString()
      # make sure request is a user and not an app
      if user_id?
         if user_id == obj.owner_user_id.toString()
            obj.is_owner = true
            obj.current_vote = "owner"
         else
            obj.is_owner = false
            obj.current_vote = "none"
            for id in obj.up_voted_by
               if id.toString() == user_id
                  obj.current_vote = "up"
                  break
            if obj.current_vote == "none"
               for id in obj.down_voted_by
                  if id.toString() == user_id
                     obj.current_vote = "down"
                     break

      delete obj.up_voted_by
      delete obj.down_voted_by
      res.json obj
      
app.post "/v1/highlights/:highlight_id/vote", auth.rookieStatus, (req, res, next) ->
   highlight_id = req.params.highlight_id
   vote = req.body.vote
   user_id = req.user._id.toString()

   return next(new InvalidArgumentError("Required: vote")) unless vote
   return next(new InvalidArgumentError("Invalid: highlight_id")) if highlight_id == "undefined"
   return next(new InvalidArgumentError("Invalid: vote, must be 'up', 'down' or 'none'")) unless (vote == "up" or vote == "down" or vote == "none")
   
   if vote == "up"
      Highlight
      .findOne({ _id: highlight_id, up_voted_by: {$ne: req.user._id } })
      .select("up_votes up_voted_by down_votes down_voted_by")
      .exec (err, highlight) ->
         return next(new MongoError(err)) if err
         return next(new InvalidArgumentError("Invalid: highlight_id or user has already up voted")) unless highlight
         
         # remove previous down vote
         for id in highlight.down_voted_by
            if id.toString() == user_id
               highlight.down_votes -= 1
               highlight.down_voted_by.pull(id)
               break


         highlight.up_votes += 1
         highlight.up_voted_by.addToSet(req.user._id)

         highlight.save (err) ->
            return next(new MongoError(err)) if err
            res.json
               status: "success"
               up_votes: highlight.up_votes
               down_votes: highlight.down_votes

   if vote == "down"
      Highlight
      .findOne({ _id: highlight_id, down_voted_by: {$ne: req.user._id } })
      .select("up_votes up_voted_by down_votes down_voted_by")
      .exec (err, highlight) ->
         return next(new MongoError(err)) if err
         return next(new InvalidArgumentError("Invalid: highlight_id or user has already down voted")) unless highlight
         
         # remove previous down vote
         for id in highlight.up_voted_by
            if id.toString() == user_id
               highlight.up_votes -= 1
               highlight.up_voted_by.pull(id)
               break

         highlight.down_votes += 1
         highlight.down_voted_by.addToSet(req.user._id)

         highlight.save (err) ->
            return next(new MongoError(err)) if err
            res.json
               status: "success"
               up_votes: highlight.up_votes
               down_votes: highlight.down_votes

   else if vote == "none"
      Highlight
      .findOne({ _id: highlight_id, $or: [ {down_voted_by: user_id}, {up_voted_by: user_id} ] })
      .select("up_votes up_voted_by down_votes down_voted_by")
      .exec (err, highlight) ->
         return next(new MongoError(err)) if err
         return next(new InvalidArgumentError("Invalid: highlight_id or user has not voted")) unless highlight
         found = false

         for id in highlight.down_voted_by
            if id.toString() == user_id
               found = true
               highlight.down_votes -= 1
               highlight.down_voted_by.pull(id)
               break

         unless found
            for id in highlight.up_voted_by
               if id.toString() == user_id
                  highlight.up_votes -= 1
                  highlight.up_voted_by.pull(id)
                  break

         highlight.save (err) ->
            return next(new MongoError(err)) if err
            res.json
               status: "success"
               up_votes: highlight.up_votes
               down_votes: highlight.down_votes

app.get "/v1/highlights/:highlight_id/comments", auth.rookieStatus, (req, res, next) ->
   highlight_id = req.params.highlight_id
   limit = req.query.limit or 10
   limit = parseInt(limit)
   limit = if limit > 20 then 20 else limit
   skip = req.query.skip or 0
   skip = parseInt(skip)
   reverse = req.query.reverse or false
   reverse = if typeof reverse == "string" and reverse.toLowerCase() == "true" or reverse == true then true else false

   return next(new InvalidArgumentError("Invalid: highlight_id")) if highlight_id == "undefined"

   if skip == 0
      slice = if reverse then limit * -1 else limit
   else
      start = if reverse then skip * -1 - limit else skip
      slice = [ start, limit ] 

   Highlight
   .findById(highlight_id)
   .select({ comments: { $slice: slice }, comment_count: 1 })
   .lean()
   .exec (err, highlight) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: highlight_id")) unless highlight
      comments = highlight.comments or []
      comments = comments.reverse() if reverse
      
      res.json
         meta: 
            skip: skip
            limit: limit
            reverse: reverse
            count: highlight.comment_count
         comments: comments

app.post "/v1/highlights/:highlight_id/comments", auth.rookieStatus, (req, res, next) ->
   highlight_id = req.params.highlight_id
   content = req.body.content
   profile_id = req.body.team_profile_id
   
   return next(new InvalidArgumentError("Invalid: highlight_id")) if highlight_id == "undefined"
   return next(new InvalidArgumentError("Require: content")) unless content

   async.parallel
      highlight: (done) -> 
         Highlight.findById highlight_id, "comment_count team_id", done
      profile: (done) -> 
         TeamProfile.findById profile_id, "name user_id team_id team_name verified profile_image_url", done
   , (err, results) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: highlight_id")) unless results.highlight
      return next(new InvalidArgumentError("Invalid: team_profile_id")) unless results.profile

      comment = 
         _id: new mongoose.Types.ObjectId
         owner_id: results.profile._id
         owner_user_id: results.profile.user_id
         owner_name: results.profile.name
         owner_verified: results.profile.verified
         owner_profile_image_url: results.profile.profile_image_url
         team_id: results.profile.team_id
         team_name: results.profile.team_name
         content: content  
         
      # Add to replies
      Highlight.update { _id: results.highlight._id },
         $push: { comments: comment }
         comment_count: results.highlight.comment_count + 1
      , (err, result) ->
         return next(new MongoError(err)) if err
         return next(new RestError("Failed to save comment")) unless result == 1
         res.json 
            meta: { count: results.highlight.comment_count + 1 }
            comment: comment

shareLink = "fans.fannect.me"

app.post "/v1/highlights/:highlight_id/share", auth.rookieStatus, (req, res, next) ->
   twitter = req.body.twitter?.toString()?.toLowerCase() == "true"
   caption = req.body.caption
   
   return next(new InvalidArgumentError("No twitter account connected to this user")) unless req.user.twitter
   return res.json status: "success" unless twitter

   Highlight.findById req.params.highlight_id, "short_id caption", (err, highlight) ->
      return next(new ResourceNotFoundError("Not found: Highlight")) unless highlight

      caption = req.body.caption or highlight.caption
      tweet = "#{caption} #{shareLink}/#{highlight.short_id}"

      twitterReq.tweet req.user.twitter, tweet, (err) ->      
         return next(err) if err
         res.json status: "success"










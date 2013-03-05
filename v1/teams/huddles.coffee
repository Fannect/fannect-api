mongoose = require "mongoose"
express = require "express"
auth = require "../../common/middleware/authenticate"
InvalidArgumentError = require "../../common/errors/InvalidArgumentError"
RestError = require "../../common/errors/RestError"
MongoError = require "../../common/errors/MongoError"
User = require "../../common/models/User"
Team = require "../../common/models/Team"
TeamProfile = require "../../common/models/TeamProfile"
Huddle = require "../../common/models/Huddle"
encoder = new (require("node-html-encoder").Encoder)("entity")
async = require "async"

app = module.exports = express()

sort_available = [ "most_active", "oldest", "newest" ]
created_by_available = [ "team", "me", "roster", "any" ]

# Uses logged in user
app.get "/v1/teams/:team_id/huddles", auth.rookieStatus, (req, res, next) ->
   team_id = req.params.team_id
   sort_by = req.query.sort_by or "most_active"
   created_by = req.query.created_by or "team"
   skip = req.query.skip or 0
   limit = req.query.limit or 20

   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"

   # Build query object up
   pull =  
      team: (done) ->
         Team.findById(team_id, "full_name conference_key conference_name league_key league_name", done)

   if created_by == "roster"
      pull.profile = (done) -> TeamProfile.findOne({ user_id: req.user._id, team_id: team_id }, "friends", done)

   # Get data in parallel
   async.parallel pull, (err, results) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: team_id")) unless results.team

      # Filter by created_by type
      if created_by == "any"
         query = Huddle.find( $or: [
            { "team_id", team_id }
            { "tags.include_key": results.team.conference_key },
            { "tags.include_key": results.team.league_key },
            { "tags.include_id": team_id }
         ])
      else
         query = Huddle.find({team_id: team_id})
      
      if created_by == "me"
         query.where("owner_user_id", req.user._id)
      
      else if created_by == "roster"
         query.or([
            { owner_user_id: req.user._id },
            { owner_id: { $in: results.profile.friends } }
         ])

      # Sort by
      if sort_by == "oldest" then query.sort({ _id: 1, last_comment_time: -1 })
      if sort_by == "newest" then query.sort({ _id: -1, last_comment_time: -1 })
      else query.sort({ last_comment_time: -1, _id: -1 })

      query
      .limit(limit)
      .skip(skip)
      .select("owner_id owner_user_id owner_name owner_verified topic reply_count replies team_id team_name rating rating_count last_comment_time")
      .exec (err, huddles) ->
         return next(new MongoError(err)) if err
         res.json huddles

# Create a huddle
app.post "/v1/teams/:team_id/huddles", auth.rookieStatus, (req, res, next) ->
   team_id = req.params.team_id
   profile_id = req.body.team_profile_id
   topic = req.body.topic
   content = req.body.content
   include_teams = req.body.include_teams or []
   include_league = req.body.include_league
   include_conference = req.body.include_conference

   # force teams to be an array
   if include_teams and typeof include_teams == "string"
      include_teams = [include_teams]

   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"
   return next(new InvalidArgumentError("Required: team_profile_id")) unless profile_id
   return next(new InvalidArgumentError("Required: topic")) unless topic
   return next(new InvalidArgumentError("Required: content")) unless content
   
   async.parallel
      team: (done) ->
         Team.findById(team_id, "full_name league_key league_name conference_key conference_name", done)
      teams: (done) ->
         Team.find({_id: $in: include_teams}, "team_name", done)
      profile: (done) ->
         TeamProfile.findById(profile_id, "name user_id verified", done)
   , (err, results) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: team_id")) unless results.team
      return next(new InvalidArgumentError("Invalid: team_profile_id")) unless results.profile
      
      huddle = new Huddle({
         team_id: results.team._id
         team_name: results.team.full_name
         owner_id: results.profile._id
         owner_user_id: results.profile.user_id
         owner_name: results.profile.name
         owner_verified: results.profile.verified
         topic: encoder.htmlEncode(topic)
      })

      # Add first reply
      huddle.replies.push({
         owner_id: results.profile._id
         owner_user_id: results.profile.user_id
         owner_name: results.profile.name
         owner_verified: results.profile.verified
         team_id: results.profile.team_id
         team_name: results.profile.team_name
         content: encoder.htmlEncode(content)
      })
      huddle.reply_count = 1

      # Add team tags
      for team in results.teams
         huddle.tags.push({
            include_id: team._id
            type: "team"
            name: team.full_name
         })
      
      # Add league tag
      if include_league
         huddle.tags.push({
            include_key: results.team.league_key
            type: "league"
            name: results.team.league_name
         })

      # Add conference tag
      if include_conference
         huddle.tags.push({
            include_key: results.team.conference_key
            type: "conference"
            name: results.team.conference_name
         })

      huddle.save (err) ->
         return next(new MongoError(err)) if err
         res.json huddle.toObject()

app.get "/v1/teams/:team_id/huddles/:huddle_id", auth.rookieStatus, (req, res, next) ->
   team_id = req.params.team_id
   huddle_id = req.params.huddle_id
   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"
   return next(new InvalidArgumentError("Invalid: huddle_id")) if huddle_id == "undefined"

   Huddle
   .findOne({ _id: huddle_id })
   .select(_id:1,owner_user_id:1, owner_name:1, owner_verified:1, topic:1, 
      reply_count:1, replies:{$slice:5}, team_id:1, team_name:1, rating:1, 
      rating_count:1, last_comment_time:1, tags:1)
   .exec (err, huddle) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: huddle_id")) unless huddle
      return next(new InvalidArgumentError("Invalid: huddle_id, does not match team_id")) if huddle.team_id == team_id
      res.json huddle

app.get "/v1/teams/:team_id/huddles/:huddle_id/replies", auth.rookieStatus, (req, res, next) ->
   team_id = req.params.team_id
   huddle_id = req.params.huddle_id
   limit = req.query.limit or 10
   limit = parseInt(limit)
   limit = if limit > 20 then 20 else limit
   skip = req.query.skip or 0
   skip = parseInt(skip)
   reverse = req.query.reverse or false

   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"
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
      
app.post "/v1/teams/:team_id/huddles/:huddle_id/replies", auth.rookieStatus, (req, res, next) ->
   team_id = req.params.team_id
   huddle_id = req.params.huddle_id
   content = req.body.content
   profile_id = req.body.team_profile_id

   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"
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
               content: encoder.htmlEncode(content)  
         reply_count: results.huddle.reply_count + 1
         last_comment_time: new Date()
      , (err) ->
         return next(new MongoError(err)) if err
         res.json status: "success" 

app.post "/v1/teams/:team_id/huddles/:huddle_id/rating", auth.rookieStatus, (req, res, next) ->
   team_id = req.params.team_id
   huddle_id = req.params.huddle_id
   profile_id = req.body.team_profile_id
   rating = req.body.rating or 0
   rating = parseInt(rating)

   return next(new InvalidArgumentError("Required: team_profile_id")) unless profile_id
   return next(new InvalidArgumentError("Required: rating")) unless rating
   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"
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

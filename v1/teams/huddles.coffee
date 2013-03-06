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
      if sort_by == "oldest" then query.sort({ _id: 1, last_reply_time: -1 })
      if sort_by == "newest" then query.sort({ _id: -1, last_reply_time: -1 })
      else query.sort({ last_reply_time: -1, _id: -1 })

      query
      .limit(limit)
      .skip(skip)
      .select("owner_id owner_user_id owner_name owner_verified topic reply_count replies team_id team_name rating rating_count last_reply_time")
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
         topic: topic
      })

      # Add first reply
      huddle.replies.push({
         owner_id: results.profile._id
         owner_user_id: results.profile.user_id
         owner_name: results.profile.name
         owner_verified: results.profile.verified
         team_id: results.team._id
         team_name: results.team.full_name
         content: content
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

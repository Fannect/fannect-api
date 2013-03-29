mongoose = require "mongoose"
express = require "express"
auth = require "../../common/middleware/authenticate"
InvalidArgumentError = require "../../common/errors/InvalidArgumentError"
RestError = require "../../common/errors/RestError"
MongoError = require "../../common/errors/MongoError"
User = require "../../common/models/User"
Team = require "../../common/models/Team"
TeamProfile = require "../../common/models/TeamProfile"
Highlight = require "../../common/models/Highlight"
async = require "async"

app = module.exports = express()

# Uses logged in user
app.get "/v1/teams/:team_id/highlights", auth.rookieStatus, (req, res, next) ->
   team_id = req.params.team_id
   sort_by = req.query.sort_by or "most_popular"
   created_by = req.query.created_by or "team"
   limit = req.query.limit or 10
   limit = parseInt(limit)
   limit = if limit > 40 then 40 else limit
   skip = req.query.skip or 0
   skip = parseInt(skip)
   
   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"

   # Filter by created_by type
   if created_by == "any" then query = Highlight.find()
   else if created_by == "team" then query = Highlight.find({ team_id: team_id })
   else if created_by == "me" then query = Highlight.find({ owner_user_id: req.user._id })
   else query = Highlight.find({ team_id: team_id, game_type: created_by })

   # Sort by
   if sort_by == "newest" then query.sort("-_id -up_vote")
   else if sort_by == "most_popular" then query.sort("-up_vote")
   else return next(new InvalidArgumentError("Invalid: sort_by. Must be 'newest' or 'most_popular'"))



   query
   .skip(skip)
   .limit(limit)
   .select("owner_id owner_user_id owner_name owner_profile_image_url team_name team_id owner_verified caption image_url comment_count up_votes up_voted_by down_votes down_voted_by")
   .exec (err, highlights) ->
      return next(new MongoError(err)) if err

      user_id = req.user._id  
      results = []

      for highlight in highlights 
         obj = highlight.toObject()
         results.push(obj)
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
         
      res.json results
      
# Create a highlight
app.post "/v1/teams/:team_id/highlights", auth.rookieStatus, (req, res, next) ->
   team_id = req.params.team_id
   caption = req.body.caption
   image_url = req.body.image_url
   game_type = req.body.game_type
   game_meta = req.body.game_meta

   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"
   return next(new InvalidArgumentError("Required: image_url")) unless image_url
   return next(new InvalidArgumentError("Required: game_type")) unless game_type
   
   game_types = ["spirit_wear", "photo_challenge", "gameday_pics", "picture_with_a_player"]
   unless (game_type in game_types)
      return next(new InvalidArgumentError("Invalid: game_type must be '#{game_types.join("', '")}'"))

   TeamProfile
   .findOne({ user_id: req.user._id, team_id: team_id })
   .select("name user_id team_name team_id verified profile_image_url")
   .exec (err, profile) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: user doesn't have a profile with this team")) unless profile
   
      Highlight.createAndAttach profile,
         image_url: image_url
         caption: caption
         game_type: game_type
         game_meta: game_meta
      , (err, highlight) ->
         return next(err) if err
         res.json highlight.toObject()

express = require "express"
auth = require "../../common/middleware/authenticate"
TeamProfile = require "../../common/models/TeamProfile"
Team = require "../../common/models/Team"
MongoError = require "../../common/errors/MongoError"

app = module.exports = express()

# Get team profiles
app.get "/v1/me/teams", auth.rookie, (req, res, next) ->
   TeamProfile
   .find()
   .where("_id").in(req.user.team_profiles)
   .select("_id team_name")
   .exec (err, team_profiles) ->
      return next(new MongoError(err)) if err
      res.json team_profiles.toObject()

# Add team profile
app.post "/v1/me/teams", auth.rookie, (req, res, next) ->
   team_id = req.body.team_id

   Team
   .findOne("_id": team_id)
   .select("abbreviation nickname team_key")
   .exec (err, team) ->
      return next(new MongoError(err)) if err
         
      TeamProfile.create
         user_id: req.user._id 
         name: "#{req.user.first_name} #{req.user.last_name}"
         team_id: team_id
         team_key: team.team_key
         team_name: "#{team.abbreviation} #{team.nickname}" 
      , (err, this_profile) ->
         return next(new MongoError(err)) if err

         TeamProfile
         .find({ team_id: team_id, user_id: { $in: req.user.friends }})
         .select("friends")
         .exec (err, team_profiles) ->
            return next(new MongoError(err)) if err

            updated = [this_profile.save]

            for profile in team_profiles
               profile.friends.push this_profile._id
               this_profile.friends.push profile._id
               updated.push profile.save

            async.parallel updated, (err) ->
               return next(new MongoError(err)) if err
               res.json
                  status: "success"





app.get "/v1/me/teams/:team_profile_id", auth.rookie, (req, res, next) ->
   
   teams = [
      {
         user_id: "blahblah"
         team_profile_id: "12345"
         name: "Kansas State Wildcats"
         team_image_url: "" 
         team_id: "something"
         roster: 0
         points: 0
         rank: 0
      },
      {
         user_id: "blahblah"
         team_profile_id: "54321"
         name: "Kansas City Chiefs"
         team_image_url: "" 
         team_id: "something"
         roster: 0
         points: 0
         rank: 0
      }
   ]

   res.json teams[req.params.team_profile_id]

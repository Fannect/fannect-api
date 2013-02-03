express = require "express"
rest = require "request"
TeamProfile = require "../../../common/models/TeamProfile"
Team = require "../../../common/models/Team"
MongoError = require "../../../common/errors/MongoError"
InvalidArgumentError = require "../../../common/errors/InvalidArgumentError"

app = module.exports = express()

app.get "/v1/me/teams/:team_profile_id/games/gameFace", (req, res, next) ->
   profile_id = req.params.team_profile_id
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"

   TeamProfile
   .findById(profile_id)
   .select("user_id team_id waiting_events")
   .exec (err, profile) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: team_profile_id")) unless profile
      # unless profile.user_id == req.user._id
      #    return next(new InvalidArgumentError("Invalid: team_profile_id, does not belong to this user"))

      Team
      .findById(profile.team_id)
      .select("full_name schedule.pregame")
      .exec (err, team) ->

         
         
         console.log "team", team
         console.log "profile", profile
         res.json status: "success"

   # gameInfo = 
   #    available: true
   #    face_value: "off"
   #    home_team:
   #       name: "Kansas Jayhawks"
   #       record: "(31-3, 14-2)"
   #    away_team:
   #       name: "Missouri Tigers"
   #       record: "(31-3, 14-2)"
   # res.json gameInfo
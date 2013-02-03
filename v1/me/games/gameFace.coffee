express = require "express"
rest = require "request"
TeamProfile = require "../../../common/models/TeamProfile"
Team = require "../../../common/models/Team"
MongoError = require "../../../common/errors/MongoError"
InvalidArgumentError = require "../../../common/errors/InvalidArgumentError"
RestError = require "../../../common/errors/RestError"
auth = require "../../../common/middleware/authenticate"
gameDay = require "../../../common/utils/gameDay"

app = module.exports = express()

app.get "/v1/me/teams/:team_profile_id/games/gameFace", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"

   gameDay.get profile_id, 
      gameType: "game_face"
      meta:
         face_on: false
   , (err, result) ->
      next(err) if err
      res.json result

app.post "/v1/me/teams/:team_profile_id/games/gameFace", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"

   gameDay.post profile_id, 
      gameType: "game_face"
   , (err, result) ->
      return next(err) if err

      res.json status: "success"



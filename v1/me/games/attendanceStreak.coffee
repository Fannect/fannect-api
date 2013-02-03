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

app.get "/v1/me/teams/:team_profile_id/games/attendanceStreak", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"

   gameDay.get profile_id,
      gameType: "attendance_streak", 
      meta:
         checked_in: false
   , (err, result) ->
      next(err) if err
      res.json result

app.post "/v1/me/teams/:team_profile_id/games/attendanceStreak", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"
   return next(new InvalidArgumentError("Required: lat and lng")) if not req.body.lat or not req.body.lng

   gameDay.post profile_id, 
      gameType: "attendance_streak"
      meta: 
         lat: req.body.lat
         lng: req.body.lng
         checked_in: true
   , (err, result) ->
      return next(err) if err
      res.json status: "success"

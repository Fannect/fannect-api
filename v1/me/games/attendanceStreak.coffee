express = require "express"
rest = require "request"
TeamProfile = require "../../../common/models/TeamProfile"
Team = require "../../../common/models/Team"
MongoError = require "../../../common/errors/MongoError"
InvalidArgumentError = require "../../../common/errors/InvalidArgumentError"
RestError = require "../../../common/errors/RestError"
auth = require "../../../common/middleware/authenticate"
GameStatus = require "../../../common/GameStatus/GameStatus"

app = module.exports = express()

app.get "/v1/me/teams/:team_profile_id/games/attendanceStreak", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"

   GameStatus
   .get(profile_id, "attendance_streak")
   .availability("tillEnd")
   .meta "raw",
      checked_in: false
   .exec (err, result) ->
      next(err) if err
      res.json result

app.post "/v1/me/teams/:team_profile_id/games/attendanceStreak", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"
   return next(new InvalidArgumentError("Required: lat and lng")) if not req.body.lat or not req.body.lng

   GameStatus
   .set(profile_id, "attendance_streak")
   .availability("tillEnd")
   .meta "raw",
      lat: req.body.lat
      lng: req.body.lng
      checked_in: true
   .exec (err) ->
      return next(err) if err
      res.json status: "success"
      
      
# app.get "/v1/me/teams/:team_profile_id/games/attendanceStreak/mock0", auth.rookieStatus, (req, res, next) ->
#    res.json {
#       home_team: { name: 'Boston Celtics' },
#       stadium: { name: 'Some Stadium', location: 'KCMO', lat: 39.097328, lng: -94.579968 },
#       available: false 
#    }

# app.get "/v1/me/teams/:team_profile_id/games/attendanceStreak/mock1", auth.rookieStatus, (req, res, next) ->
#    res.json {
#       game_time: new Date("Mon Feb 04 2013 12:29:18 GMT-0600 (CST)"),
#       home_team: { name: 'Boston Celtics' },
#       away_team: { name: 'Fannect a Squad' },
#       stadium: { name: 'Some Stadium', location: 'KCMO', lat: 39.097328, lng: -94.579968 },
#       preview: [ ],
#       available: false 
#    }

# app.get "/v1/me/teams/:team_profile_id/games/attendanceStreak/mock2", auth.rookieStatus, (req, res, next) ->
#    res.json {
#       game_time: new Date("Mon Feb 04 2013 12:29:18 GMT-0600 (CST)"),
#       home_team: { name: 'Boston Celtics', record: "(13-3)" },
#       away_team: { name: 'Fannect a Squad', record: "(18-1)" },
#       stadium: { name: 'Some Stadium', location: 'KCMO', lat: 39.097328, lng: -94.579968 },
#       preview: [ ],
#       available: true,
#       meta: { checked_in: false }
#    }
# app.get "/v1/me/teams/:team_profile_id/games/attendanceStreak/mock3", auth.rookieStatus, (req, res, next) ->
#    res.json {
#       game_time: new Date("Mon Feb 04 2013 12:29:18 GMT-0600 (CST)"),
#       home_team: { name: 'Boston Celtics' },
#       away_team: { name: 'Fannect a Squad' },
#       stadium: { name: 'Some Stadium', location: 'KCMO', lat: 39.097328, lng: -94.579968 },
#       preview: [ ],
#       available: true,
#       meta: { lng: 50, lat: 50, checked_in: true }
#    }

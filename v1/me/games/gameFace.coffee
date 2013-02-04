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

app.get "/v1/me/teams/:team_profile_id/games/gameFace/mock0", auth.rookieStatus, (req, res, next) ->
   res.json {
      home_team: { name: 'Boston Celtics' },
      available: false 
      stadium: { name: 'Some Stadium', location: 'KCMO', lat: 42.366289, lng: -71.06222 },
   }

app.get "/v1/me/teams/:team_profile_id/games/gameFace/mock1", auth.rookieStatus, (req, res, next) ->
   res.json {
      game_time: new Date("Mon Feb 04 2013 12:29:18 GMT-0600 (CST)"),
      home_team: { name: 'Boston Celtics' },
      away_team: { name: 'Fannect a Squad' },
      stadium: { name: 'Some Stadium', location: 'KCMO', lat: 42.366289, lng: -71.06222 },
      preview: [ ],
      available: false 
   }

app.get "/v1/me/teams/:team_profile_id/games/gameFace/mock2", auth.rookieStatus, (req, res, next) ->
   res.json {
      game_time: new Date("Mon Feb 04 2013 12:29:18 GMT-0600 (CST)"),
      home_team: { name: 'Boston Celtics' },
      away_team: { name: 'Fannect a Squad' },
      stadium: { name: 'Some Stadium', location: 'KCMO', lat: 42.366289, lng: -71.06222 },
      preview: [ ],
      available: true,
      meta: { face_on: false }
   }

app.get "/v1/me/teams/:team_profile_id/games/gameFace/mock3", auth.rookieStatus, (req, res, next) ->
   res.json {
      game_time: new Date("Mon Feb 04 2013 12:29:18 GMT-0600 (CST)"),
      home_team: { name: 'Boston Celtics' },
      away_team: { name: 'Fannect a Squad' },
      stadium: { name: 'Some Stadium', location: 'KCMO', lat: 42.366289, lng: -71.06222 },
      preview: [ ],
      available: true,
      meta: { face_on: true }
   }



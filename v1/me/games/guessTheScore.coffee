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

app.get "/v1/me/teams/:team_profile_id/games/guessTheScore", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"

   gameDay.get profile_id,
      gameType: "guess_the_score", 
      meta:
         picked: false
   , (err, result) ->
      next(err) if err
      res.json result

app.post "/v1/me/teams/:team_profile_id/games/guessTheScore", auth.rookieStatus, (req, res, next) ->
   profile_id = req.params.team_profile_id
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"
   return next(new InvalidArgumentError("Required: home_score and away_score")) if not req.body.home_score or not req.body.away_score

   gameDay.post profile_id, 
      gameType: "guess_the_score"
      meta: 
         home_score: req.body.home_score
         away_score: req.body.away_score
         picked: true
   , (err, result) ->
      return next(err) if err
      res.json status: "success"

app.get "/v1/me/teams/:team_profile_id/games/guessTheScore/mock0", auth.rookieStatus, (req, res, next) ->
   res.json {
      home_team: { name: 'Boston Celtics' },
      available: false 
      stadium: { name: 'Some Stadium', location: 'KCMO', lat: 42.366289, lng: -71.06222 },
   }

app.get "/v1/me/teams/:team_profile_id/games/guessTheScore/mock1", auth.rookieStatus, (req, res, next) ->
   res.json {
      game_time: new Date("Mon Feb 04 2013 12:29:18 GMT-0600 (CST)"),
      home_team: { name: 'Boston Celtics' },
      away_team: { name: 'Fannect a Squad' },
      stadium: { name: 'Some Stadium', location: 'KCMO', lat: 42.366289, lng: -71.06222 },
      preview: [ ],
      available: false 
   }

app.get "/v1/me/teams/:team_profile_id/games/guessTheScore/mock2", auth.rookieStatus, (req, res, next) ->
   res.json {
      game_time: new Date("Mon Feb 04 2013 12:29:18 GMT-0600 (CST)"),
      home_team: { name: 'Boston Celtics' },
      away_team: { name: 'Fannect a Squad' },
      stadium: { name: 'Some Stadium', location: 'KCMO', lat: 42.366289, lng: -71.06222 },
      preview: [ ],
      available: true,
      meta: { picked: false }
   }

app.get "/v1/me/teams/:team_profile_id/games/guessTheScore/mock3", auth.rookieStatus, (req, res, next) ->
   res.json {
      game_time: new Date("Mon Feb 04 2013 12:29:18 GMT-0600 (CST)"),
      home_team: { name: 'Boston Celtics' },
      away_team: { name: 'Fannect a Squad' },
      stadium: { name: 'Some Stadium', location: 'KCMO', lat: 42.366289, lng: -71.06222 },
      preview: [ ],
      available: true,
      meta: { picked: true, away_score: 23, home_score: 43 }
   }





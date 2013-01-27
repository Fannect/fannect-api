express = require "express"
auth = require "../common/middleware/authenticate"
Team = require "../common/models/Team"
TeamProfile = require "../common/models/TeamProfile"
MongoError = require "../common/errors/MongoError"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"


app = module.exports = express()

app.get "/v1/sports", auth.rookieStatus, (req, res, next) ->
   Team
   .aggregate { $group: { _id: "$sport_key", sport_name: { $first: "$sport_name"}}}
   , { $sort: { sport_name: 1 }}
   , { $project: { _id: 0, sport_key: "$_id", sport_name: 1 }}
   , (err, sports) ->
      return next(new MongoError(err)) if err
      res.json sports

app.get "/v1/sports/:sport_key/leagues", auth.rookieStatus, (req, res, next) ->
   sport_key = req.params.sport_key

   Team
   .aggregate { $match: { sport_key: sport_key }}
   , { $group: { _id: "$league_key", league_name: { $first: "$league_name"}}}
   , { $sort: { league_name: 1 }}
   , { $project: { _id: 0, league_key: "$_id", league_name: 1 }}
   , (err, leagues) ->
      return next(new MongoError(err)) if err
      res.json leagues

app.get "/v1/sports/:sport_key/leagues/:league_key/teams", auth.rookieStatus, (req, res, next) ->
   sport_key = req.params.sport_key
   league_key = req.params.league_key

   Team
   .find({sport_key: sport_key, league_key: league_key})
   .sort("abbreviation")
   .select("abbreviation nickname")
   .exec (err, teams) ->
      return next(new MongoError(err)) if err
      res.json teams
   
   # .aggregate { $match: { sport_key: sport_key, league_key: league_key }}
   # , { $group: { _id: "$team_id", abbreviation: { $first: "$abbreviation"}, nickname: { $first: "$nickname"}}}
   # , { $project: { _id: 1, abbreviation: 1, nickname: 1 }}
   # , { $sort: { abbreviation: 1 }}
   # , (err, teams) ->
   #    return next(new MongoError(err)) if err
   #    res.json teams



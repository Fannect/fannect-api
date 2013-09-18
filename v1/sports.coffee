express = require "express"
auth = require "../common/middleware/authenticate"
Team = require "../common/models/Team"
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
   excluded_keys = [ "l.ncaa.org.mfoot.div1.aa" ]

   Team
   .aggregate { $match: { sport_key: sport_key, league_key: { $nin: excluded_keys } }}
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
   .sort("full_name")
   .select("mascot location_name full_name")
   .exec (err, teams) ->
      return next(new MongoError(err)) if err
      res.json teams

app.get "/v1/sports/:sport_key/teams", auth.rookieStatus, (req, res, next) ->
   sport_key = req.params.sport_key
   q = req.query.q or ""
   skip = req.query.skip or 0
   limit = req.query.limit or 20
   limit = if limit > 40 then 40 else limit

   return res.json [] if q.length < 1 

   regex = new RegExp("(|.*[\s]+)(#{q}).*", "i")

   Team
   .find({ $or: [{ full_name: regex }, { aliases: regex }] })
   .where("sport_key", sport_key)
   .skip(skip)
   .limit(limit)
   .sort("full_name")
   .select("mascot full_name location_name")
   .exec (err, teams) ->
      return next(new MongoError(err)) if err
      res.json teams


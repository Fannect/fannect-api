express = require "express"
auth = require "../../common/middleware/authenticate"
InvalidArgumentError = require "../../common/errors/InvalidArgumentError"
RestError = require "../../common/errors/RestError"
MongoError = require "../../common/errors/MongoError"
Team = require "../../common/models/Team"
Group = require "../../common/models/Group"

app = module.exports = express()

app.get "/v1/teams/:team_id/groups", auth.rookieStatus, (req, res, next) ->
   tags = req.query.tags?.split(",")
   skip = req.query.skip or 0
   limit = req.query.limit or 40
   team_id = req.params.team_id

   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"
   
   query = team_id: req.params.team_id

   if tags
      tags[i] = tag.trim() for tag, i in tags
      query.tags = { "$all": tags }

   Group
   .find(query)
   .skip(skip)
   .limit(limit)
   .exec (err, groups) ->
      return next(new MongoError(err)) if err
      res.json groups

app.post "/v1/teams/:team_id/groups", auth.rookieStatus, (req, res, next) ->
   name = req.body.name
   tags = req.body.tags
   team_id = req.params.team_id
   return next(new InvalidArgumentError("Required: name")) unless name
   return next(new InvalidArgumentError("Invalid: name")) if name == "undefined"
   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"

   Group.createAndAttach {
      name: name
      tags: tags
      team_id: team_id
   }, (err) ->
      return next(err) if err
      res.json status: "success"

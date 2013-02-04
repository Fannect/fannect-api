express = require "express"
auth = require "../common/middleware/authenticate"
csvParser = require "../common/utils/csvParser"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"
RestError = require "../common/errors/RestError"
MongoError = require "../common/errors/MongoError"
TeamProfile = require "../common/models/TeamProfile"
Stadium = require "../common/models/Stadium"

app = module.exports = express()

app.post "/v1/stadiums", (req, res, next) ->
# app.post "/v1/stadiums", auth.hof, (req, res, next) ->
   if req.files?.stadiums?.path
      csvParser.parseStadiums req.files.stadiums.path, (err, count) ->
         return next(err) if err
         res.json
            status: "success"
            count: count
   else
      next(new InvalidArgumentError("Required: stadiums file"))
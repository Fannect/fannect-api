express = require "express"
authenticate = require "../common/middleware/authenticate"
csvTeam = require "../common/utils/csvTeam"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"
RestError = require "../common/errors/RestError"
MongoError = require "../common/errors/MongoError"
UserProfile = require "../common/models/UserProfile"
Team = require "../common/models/Team"

app = module.exports = express()

app.get "/v1/teams", authenticate, (req, res, next) ->
   UserProfile
   .find({ user_id: req.user.user_id })
   .select("name team_key team_id team_name points team_image_url profile_image_url trash_talk")
   .exec (err, data) ->
      return next(new MongoError(err))
      res.json data

app.post "/v1/teams", authenticate.hof, (req, res, next) ->
   if req.files?.teams?.path
      csvTeam req.files.teams.path, (err, count) ->
         return next(err) if err
         res.json
            status: "success"
            count: count
   else
      next(new InvalidArgumentError("Required: teams file"))

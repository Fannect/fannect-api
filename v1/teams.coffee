express = require "express"
auth = require "../common/middleware/authenticate"
csvTeam = require "../common/utils/csvTeam"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"
RestError = require "../common/errors/RestError"
MongoError = require "../common/errors/MongoError"
TeamProfile = require "../common/models/TeamProfile"
Team = require "../common/models/Team"

app = module.exports = express()

app.get "/v1/teams", auth.rookie, (req, res, next) ->
   TeamProfile
   .find({ user_id: req.user.user_id })
   .select("name team_key team_id team_name points team_image_url profile_image_url trash_talk")
   .exec (err, data) ->
      return next(new MongoError(err)) if err
      res.json data

app.post "/v1/teams", auth.rookie.hof, (req, res, next) ->
   if req.files?.teams?.path
      csvTeam req.files.teams.path, (err, count) ->
         return next(err) if err
         res.json
            status: "success"
            count: count
   else
      next(new InvalidArgumentError("Required: teams file"))

app.get "/v1/teams/:team_id/users", (req, res, next) ->
   team_id = req.params.team_id
   q = req.query.q
   friends_of = req.query.friends_of
   limit = parseInt(req.query.limit or 30)
   min = req.query.min

   query = TeamProfile.where("team_id", team_id)

   if q
      regex = if q then new RegExp("(|.*[\s]+)(#{q}).*", "i")
      query = query.where("name", regex)

   if friends_of
      query = query.where("friends", friends_of)

   if min
      query = query.find($min:{name: min}).skip(1)

   query
   .limit(limit)
   .sort("name")
   .select("profile_image_url name")
   .exec (err, profiles) ->
      return next(new MongoError(err)) if err
      res.json
         next_page_min: if profiles.length == limit then profiles[profiles.length-1].name else null
         data: profiles
      
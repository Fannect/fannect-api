express = require "express"
auth = require "../common/middleware/authenticate"
csvParser = require "../common/utils/csvParser"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"
RestError = require "../common/errors/RestError"
MongoError = require "../common/errors/MongoError"
TeamProfile = require "../common/models/TeamProfile"
Team = require "../common/models/Team"

app = module.exports = express()

app.get "/v1/teams", auth.rookieStatus, (req, res, next) ->
   TeamProfile
   .find({ user_id: req.user.user_id })
   .select("name team_key team_id team_name points team_image_url profile_image_url trash_talk")
   .exec (err, data) ->
      return next(new MongoError(err)) if err
      res.json data

app.post "/v1/teams", auth.hofStatus, (req, res, next) ->
   if req.files?.teams?.path
      csvParser.parseTeams req.files.teams.path, (err, count) ->
         return next(err) if err
         res.json
            status: "success"
            count: count
   else
      next(new InvalidArgumentError("Required: teams file"))

app.get "/v1/teams/:team_id", auth.rookieStatus, (req, res, next) ->
   content = req.query.content
   team_id = req.params.team_id
   return next(new InvalidArgumentError("Required: content")) unless content
   return next(new InvalidArgumentError("Invalid: content")) unless content == "next_game"
   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"

   Team
   .findOne({ _id: req.params.team_id })
   .select("schedule.pregame full_name")
   .exec (err, team) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: team_id")) unless team_id
      return res.json {} unless team.schedule?.pregame

      game = team.schedule.pregame

      res.json
         event_key: game.event_key
         game_time: game.game_time
         coverage: game.coverage
         stadium_name: game.stadium_name
         stadium_location: game.stadium_location
         home_team: if game.is_home then team.full_name else game.opponent
         away_team: if game.is_home then game.opponent else team.full_name

app.get "/v1/teams/:team_id/users", auth.rookieStatus, (req, res, next) ->
   content_types = [ "standard", "gameface" ]

   team_id = req.params.team_id
   q = req.query.q
   friends_of = req.query.friends_of
   limit = req.query.limit or 20
   limit = if limit > 40 then 40 else limit
   skip = req.query.skip or 0
   content = req.query.content or "standard"

   return next(new InvalidArgumentError("Invalid: content")) unless (content in content_types)

   if q
      regex = if q then new RegExp("^(#{q.trim()})|(.*[\\s]+(#{q.trim()}))", "i")
      query = TeamProfile.where("name", regex)

   if query
      query.where("team_id", team_id)
   else
      query = TeamProfile.where("team_id", team_id)
   
   if friends_of
      query.where("friends", friends_of)

   select = "profile_image_url name verified"

   if content == "gameface"
      select += " waiting_events"

   query
   .skip(skip)
   .limit(limit)
   .sort("name")
   .select(select)
   .lean()
   .exec (err, profiles) ->
      return next(new MongoError(err)) if err

      # Transform for gameface
      transform[content](profile) for profile in profiles if content

      res.json profiles

# Transforms to run on profiles
transform =
   standard: () ->
   gameface: (profile) ->
      profile.gameface_on = false
      for event in profile.waiting_events
         if event.type == "game_face"
            profile.gameface_on = event.meta?.face_on or false
            profile.motivator = event.meta?.motivator or null
            break

      delete profile.waiting_events

      return profile

app.use require "./teams/groups"
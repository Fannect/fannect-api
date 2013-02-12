express = require "express"
rest = require "request"
auth = require "../common/middleware/authenticate"
Team = require "../common/models/Team"
TeamProfile = require "../common/models/TeamProfile"
MongoError = require "../common/errors/MongoError"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"


app = module.exports = express()

app.get "/v1/leaderboard/users/:team_id", auth.rookieStatus, (req, res, next) ->
   friends_of = req.query.friends_of
   team_id = req.params.team_id

   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"

   if friends_of
      TeamProfile
      .find({ "team_id": team_id, $or: [{"friends": friends_of}, {"_id": friends_of}]})
      .sort("-rank")
      .select("profile_image_url name points")
      .exec (err, profiles) ->
         return next(new MongoError(err)) if err
         res.json profiles
   else
      TeamProfile
      .find({ "team_id": team_id })
      .sort("-points.overall")
      .select("profile_image_url name points")
      .exec (err, profiles) ->
         return next(new MongoError(err)) if err
         res.json profiles

app.get "/v1/leaderboard/teams/:team_id/conference", auth.rookieStatus, (req, res, next) ->
   team_id = req.params.team_id
   limit = req.query.limit or 20
   limit = if limit > 40 then 40 else limit
   skip = req.query.skip or 0

   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"

   Team.findById team_id, "sport_key conference_key conference_name", (err, team) ->
      return next(new MongoError(err)) if err   
      return next(new InvalidArgumentError("Invalid team_id")) unless team
      Team
      .find({ sport_key: team.sport_key, conference_key: team.conference_key})
      .skip(skip)
      .limit(limit)
      .sort("-points.overall")
      .select("full_name mascot location_name points")
      .exec (err, teams) ->
         return next(new MongoError(err)) if err
         res.json
            conference_name: team.conference_name
            teams: teams

app.get "/v1/leaderboard/teams/:team_id/league", auth.rookieStatus, (req, res, next) ->
   team_id = req.params.team_id
   limit = req.query.limit or 20
   limit = if limit > 40 then 40 else limit
   skip = req.query.skip or 0

   return next(new InvalidArgumentError("Invalid: team_id")) if team_id == "undefined"
   
   Team.findById team_id, "sport_key league_key league_name", (err, team) ->
      return next(new MongoError(err)) if err   
      return next(new InvalidArgumentError("Invalid team_id")) unless team

      Team
      .find({ sport_key: team.sport_key, league_key:team.league_key })
      .skip(skip)
      .limit(limit)
      .sort("-points.overall")
      .select("full_name mascot location_name points")
      .exec (err, teams) ->
         return next(new MongoError(err)) if err
         res.json 
            league_name: team.league_name
            teams: teams

app.get "/v1/leaderboard/teams/:team_id/breakdown", auth.rookieStatus, (req, res, next) ->
   team_id = req.params.team_id
   Team.findById team_id, "mascot location_name full_name points", (err, team) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid team_id")) unless team
      res.json team

app.get "/v1/leaderboard/teams/:team_id/custom", auth.rookieStatus, (req, res, next) ->
   this_team_id = req.params.team_id
   other_team_id = req.query.team_id
   return next(new InvalidArgumentError("Required: team_id")) unless other_team_id
   Team.find { _id: { $in: [this_team_id, other_team_id ] }}, "points", (err, teams) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid team_id")) unless teams?.length == 2
      res.json teams



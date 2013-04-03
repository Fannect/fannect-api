express = require "express"
rest = require "request"
TeamProfile = require "../../../common/models/TeamProfile"
Team = require "../../../common/models/Team"
Highlight = require "../../../common/models/Highlight"
Config = require "../../../common/models/Config"
MongoError = require "../../../common/errors/MongoError"
InvalidArgumentError = require "../../../common/errors/InvalidArgumentError"
RestError = require "../../../common/errors/RestError"
auth = require "../../../common/middleware/authenticate"
GameStatus = require "../../../common/GameStatus/GameStatus"

app = module.exports = express()

# app.get "/v1/me/teams/:team_profile_id/games/gamedayPics", auth.rookieStatus, (req, res, next) ->
#    profile_id = req.params.team_profile_id
#    return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"

#    GameStatus
#    .get(profile_id, "attendance_streak")
#    .availability("tillEnd")
#    .meta "raw",
#       checked_in: false
#    .exec (err, result) ->
#       next(err) if err
#       res.json result

app.get "/v1/me/teams/:team_profile_id/games/photo_challenge", auth.rookieStatus, (req, res, next) ->
   Config.getPhotoChallenge (err, challenge) ->
      return next(new RestError("Failed to pull configuration data")) if err
      res.json
         available: true
         meta:
            challenge_title: challenge.title
            challenge_description: challenge.description

alwaysAvailable = (req, res, next) -> res.json({ available: true })
app.get "/v1/me/teams/:team_profile_id/games/gameday_pics", auth.rookieStatus, alwaysAvailable
app.get "/v1/me/teams/:team_profile_id/games/spirit_wear", auth.rookieStatus, alwaysAvailable
app.get "/v1/me/teams/:team_profile_id/games/picture_with_player", auth.rookieStatus, alwaysAvailable

app.post "/v1/me/teams/:team_profile_id/games/gameday_pics", auth.rookieStatus, (req, res, next) ->
   image_url = req.body.image_url
   return next(new InvalidArgumentError("Required: image_url")) unless image_url
   
   createHighlight req.params.team_profile_id,
      image_url: image_url
      caption: req.body.caption
      game_type: "gameday_pics"
   , (err, highlight) ->
      return next(err) if err
      res.json highlight.toObject()

app.post "/v1/me/teams/:team_profile_id/games/spirit_wear", auth.rookieStatus, (req, res, next) ->
   image_url = req.body.image_url
   return next(new InvalidArgumentError("Required: image_url")) unless image_url
   
   createHighlight req.params.team_profile_id,
      image_url: image_url
      caption: req.body.caption
      game_type: "spirit_wear"
   , (err, highlight) ->
      return next(err) if err
      res.json highlight.toObject()

app.post "/v1/me/teams/:team_profile_id/games/picture_with_player", auth.rookieStatus, (req, res, next) ->
   image_url = req.body.image_url
   return next(new InvalidArgumentError("Required: image_url")) unless image_url
   
   createHighlight req.params.team_profile_id,
      image_url: image_url
      caption: req.body.caption
      game_type: "picture_with_player"
   , (err, highlight) ->
      return next(err) if err
      res.json highlight.toObject()

app.post "/v1/me/teams/:team_profile_id/games/photo_challenge", auth.rookieStatus, (req, res, next) ->
   image_url = req.body.image_url
   return next(new InvalidArgumentError("Required: image_url")) unless image_url
   
   Config.getPhotoChallenge (err, challenge) ->
      return next(new RestError("Failed to pull configuration data")) if err

      createHighlight req.params.team_profile_id,
         image_url: image_url
         caption: req.body.caption
         game_type: "photo_challenge"
         game_meta: 
            challenge_title: challenge.title
            challenge_description: challenge.description
      , (err, highlight) ->
         return next(err) if err
         res.json highlight.toObject()

createHighlight = (profileId, options, cb) ->
   TeamProfile
   .findById(profileId)
   .select("name user_id team_name team_id verified profile_image_url")
   .exec (err, profile) ->
      return cb(new MongoError(err)) if err
      return cb(new InvalidArgumentError("Invalid: team_profile_id")) unless profile
   
      Highlight.createAndAttach profile, options, (err, highlight) ->
         return cb(err) if err
         cb null, highlight
express = require "express"
rest = require "request"
TeamProfile = require "../../../common/models/TeamProfile"
Team = require "../../../common/models/Team"
MongoError = require "../../../common/errors/MongoError"
InvalidArgumentError = require "../../../common/errors/InvalidArgumentError"
RestError = require "../../../common/errors/RestError"
auth = require "../../../common/middleware/authenticate"
GameStatus = require "../../../common/GameStatus/GameStatus"
async = require "async"

parse = new (require "kaiseki")(
   process.env.PARSE_APP_ID or "EP2BOLtJpCtZP1gMWc65YxIMUvum8qqjKswCESJi",
   process.env.PARSE_API_KEY or "G8ZsbWBu0Is83VVsyvWcJeAqXhL0FI7cQeJvSHxU"
)

app = module.exports = express()

getGameFace = (req, res, next) ->
   profile_id = req.params.team_profile_id
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"

   GameStatus
   .get(profile_id, "game_face")
   .availability("before")
   .meta "raw",
      face_on: false
   .exec (err, result) ->
      return next(err) if err
      res.json result

app.get "/v1/me/teams/:team_profile_id/games/gameFace", auth.rookieStatus, getGameFace
app.get "/v1/me/teams/:team_profile_id/games/game_face", auth.rookieStatus, getGameFace

postGameFace = (req, res, next) ->
   profile_id = req.params.team_profile_id
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"

   incMotivator = (info, status, next) ->
      ev = null
      for ev in info.profile.waiting_events
         break if ev.type == "game_face" and ev.event_key == status.event_key 

      # Update count of motivator if any
      if ev.meta.motivator?.team_profile_id

         TeamProfile
         .update({
            _id: ev.meta.motivator.team_profile_id
            $and: [
               { "waiting_events.event_key": status.event_key }
               { "waiting_events.type": "game_face" }
            ]
         }, {
            $inc: { "waiting_events.$.meta.motivated_count": 1 }
         })
         .exec (err, results) ->
            return next(new MongoError(err)) if err
            next()
      else
         next()

   GameStatus
   .set(profile_id, "game_face")
   .availability("before")
   .meta("extend", face_on: true)
   .afterMeta(incMotivator)
   .exec (err) ->
      return next(err) if err
      res.json status: "success"

app.post "/v1/me/teams/:team_profile_id/games/gameFace", auth.rookieStatus, postGameFace
app.post "/v1/me/teams/:team_profile_id/games/game_face", auth.rookieStatus, postGameFace

postMotivate = (req, res, next) ->
   profile_id = req.params.team_profile_id
   motivatees = req.body.motivatees
   # message = req.body.message or "Get your head in the game!"
   
   return next(new InvalidArgumentError("Invalid: team_profile_id")) if profile_id == "undefined"
   return next(new InvalidArgumentError("Invalid: motivatees")) unless motivatees

   motivatees = [motivatees] if typeof motivatees == "string"

   gs = GameStatus
      .set("game_face")
      .availability("before")
      .meta(motivatorMeta, 
         motivator: 
            team_profile_id: profile_id, 
            name: "#{req.user.first_name} #{req.user.last_name}"
            # message: message
      )

   q = async.queue (task, callback) ->
      gs.setProfileId(task)
      gs.exec(callback)
   , 20

   q.push(m) for m in motivatees
   q.drain = (err) ->
      return next(err) if err

      gs
      .setProfileId(profile_id)
      .meta(motivatedMeta, motivatees_count: motivatees.length)
      .exec (err) ->
         return next(err) if err
         res.json status: "success"

app.post "/v1/me/teams/:team_profile_id/games/gameFace/motivate", auth.rookieStatus, postMotivate
app.post "/v1/me/teams/:team_profile_id/games/game_face/motivate", auth.rookieStatus, postMotivate

motivatorMeta = (info, status, next) ->
   ev = null
   for event in info.profile.waiting_events
      if event.type == "game_face" and event.event_key == status.event_key 
         ev = event
         break

   if ev
      if ev.motivator
         return next(new InvalidArgumentError("Duplicate: Already motivated by: #{info.meta.motivator.name}"))

      ev.meta = {} unless ev.meta
      ev.meta.motivator = info.meta.motivator
      ev.markModified("meta")
   else
      info.profile.waiting_events.push
         event_key: status.event_key
         type: info.gameType
         meta: { motivator: info.meta.motivator }

   # send push
   unless process.env.NODE_TESTING
      parse.sendPushNotification 
         channels: ["user_#{info.profile.user_id}"]
         data: 
            alert: "#{info.meta.motivator.name} is motivating you to turn on your GameFace!"
            event: "gameface"
            profileId: info.profile._id
            title: "Motivated"
      , (err) ->
         console.error "Failed to send motivation push: ", err if err

   info.profile.save (err) ->
      return next(new MongoError(err)) if err      
      next()

motivatedMeta = (info, status, next) ->
   ev = null
   for event in info.profile.waiting_events
      if event.type == "game_face" and event.event_key == status.event_key 
         ev = event
         break

   if ev
      ev.meta.attempted_motivation_count = (ev.meta.attempted_motivation_count or 0) + info.meta.motivatees_count
      ev.markModified("meta")
   else
      info.profile.waiting_events.push
         event_key: status.event_key
         type: info.gameType
         meta: attempted_motivation_count: info.meta.motivatees_count
            
   info.profile.save (err) ->
      return next(new MongoError(err)) if err      
      next()

# app.get "/v1/me/teams/:team_profile_id/games/gameFace/mock0", auth.rookieStatus, (req, res, next) ->
#    res.json {
#       home_team: { name: 'Boston Celtics' },
#       available: false 
#       stadium: { name: 'Some Stadium', location: 'KCMO', lat: 42.366289, lng: -71.06222 },
#    }

# app.get "/v1/me/teams/:team_profile_id/games/gameFace/mock1", auth.rookieStatus, (req, res, next) ->
#    res.json {
#       game_time: new Date("Mon Feb 04 2013 12:29:18 GMT-0600 (CST)"),
#       home_team: { name: 'Boston Celtics' },
#       away_team: { name: 'Fannect a Squad' },
#       stadium: { name: 'Some Stadium', location: 'KCMO', lat: 42.366289, lng: -71.06222 },
#       preview: [ ],
#       available: false 
#    }

# app.get "/v1/me/teams/:team_profile_id/games/gameFace/mock2", auth.rookieStatus, (req, res, next) ->
#    res.json {
#       game_time: new Date("Mon Feb 04 2013 12:29:18 GMT-0600 (CST)"),
#       home_team: { name: 'Boston Celtics' },
#       away_team: { name: 'Fannect a Squad' },
#       stadium: { name: 'Some Stadium', location: 'KCMO', lat: 42.366289, lng: -71.06222 },
#       preview: [ ],
#       available: true,
#       meta: { face_on: false }
#    }

# app.get "/v1/me/teams/:team_profile_id/games/gameFace/mock3", auth.rookieStatus, (req, res, next) ->
#    res.json {
#       game_time: new Date("Mon Feb 04 2013 12:29:18 GMT-0600 (CST)"),
#       home_team: { name: 'Boston Celtics' },
#       away_team: { name: 'Fannect a Squad' },
#       stadium: { name: 'Some Stadium', location: 'KCMO', lat: 42.366289, lng: -71.06222 },
#       preview: [ ],
#       available: true,
#       meta: { face_on: true }
#    }



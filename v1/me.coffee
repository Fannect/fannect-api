express = require "express"
rest = require "request"
mongoose = require "mongoose"
User = require "../common/models/User"
TeamProfile = require "../common/models/TeamProfile"
auth = require "../common/middleware/authenticate"
MongoError = require "../common/errors/MongoError"
async = require "async"

sendgrid = new (require("sendgrid-web"))({ 
   user: process.env.SENDGRID_USER or "fannect", 
   key: process.env.SENDGRID_PASSWORD or "1Billion!" 
})

app = module.exports = express()

# Get this user
app.get "/v1/me", auth.rookieStatus, (req, res, next) ->
   User.findById req.user._id, "email profile_image_url first_name last_name invites twitter verified"
   , (err, user) ->
      return next(new MongoError(err)) if err

      user = user.toObject()

      # Set if user has connected twitter
      user.twitter = if user.twitter?.user_id then true else false
      res.json user

updateProfile = (req, res, next) ->
   b = req.body
   
   data = {}
   data.first_name = b.first_name if b.first_name
   data.last_name = b.last_name if b.last_name

   req.user.first_name = data.first_name if data.first_name
   req.user.last_name = data.last_name if data.last_name

   console.log "Before parallel"

   async.parallel [
      (done) -> 
         console.log "Before 1"
         User.update { _id: req.user._id }, data, (err, data) ->
            console.log "After 1"
            done(err,data)
      (done) ->
         console.log "Before 2"
         # Update name in all TeamProfiles
         if b.first_name or b.last_name
            name = "#{b.first_name or req.user.first_name} #{b.last_name or req.user.last_name}"
            TeamProfile.update { user_id: req.user._id },
               { name: name },
               { multi: true } 
            , (err, data) ->
               console.log "After 2"
               done(err,data)
      (done) -> 
         console.log "Before 3"
         auth.updateUser req.query.access_token, req.user, (err, data) ->
            console.log "After 3"
            done(err,data)
   ], (err, data) ->
      console.log "After parallel"
      return next(new MongoError(err)) if err
      res.json status: "success"

# Update this user
app.post "/v1/me/update", auth.rookieStatus, updateProfile
app.put "/v1/me", auth.rookieStatus, updateProfile

updatePush = (req, res, next) ->
   updates = push: {}
   updates["push"]["game_notice"] = req.body.game_notice if req.body.game_notice
   updates["push"]["points_notice"] = req.body.point_notice if req.body.point_notice

   User.update { _id: req.user._id }, updates, (err) ->
      return next(new MongoError(err)) if err
      res.json status: "success"

app.post "/v1/me/push/update", auth.rookieStatus, updatePush
app.put "/v1/me/push", auth.rookieStatus, updatePush


app.post "/v1/me/verified", auth.rookieStatus, (req, res, next) ->
   html = "<h2>#{req.user.first_name} #{req.user.last_name} wants to become verified.</h2>
   <p>User_id:\t #{req.user._id}<br>Email:\t #{req.user.email}</p>
   <h3>Info</h3><p>"

   for k, v of req.body
      html += "#{k}:\t#{v}<br>"
      
   html += "</p>"

   sendgrid.send
      to: "verify@fannect.me"
      from: "admin@fannect.me"
      subject: "Verification Request- #{req.user.first_name} #{req.user.last_name}"
      html: html
   , (err) ->  
      return next(new RestError(err)) if err
      res.json status: "success"

app.use require "./me/games"
app.use require "./me/invites"
app.use require "./me/teams"
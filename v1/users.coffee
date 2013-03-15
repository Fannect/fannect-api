express = require "express"
rest = require "request"
auth = require "../common/middleware/authenticate"
TeamProfile = require "../common/models/TeamProfile"
Huddle = require "../common/models/Huddle"
Team = require "../common/models/Team"
User = require "../common/models/User"
MongoError = require "../common/errors/MongoError"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"
mongoose = require "mongoose"
async = require "async"
 
parse = new (require "kaiseki")(
   process.env.PARSE_APP_ID or "EP2BOLtJpCtZP1gMWc65YxIMUvum8qqjKswCESJi",
   process.env.PARSE_API_KEY or "G8ZsbWBu0Is83VVsyvWcJeAqXhL0FI7cQeJvSHxU"
)

app = module.exports = express()

app.post "/v1/users/:user_id/invite", auth.rookieStatus, (req, res, next) ->
   other_id = req.params.user_id
   inviter_id = req.body.inviter_user_id

   User.findById inviter_id, "first_name last_name", (err, inviter) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: inviter_user_id")) unless inviter
      
      User.findById other_id, "invites", (err, other) ->
         return next(new MongoError(err)) if err
         
         for id in other.invites 
            if inviter_id == id.toString()
               return next(new MongoError("Duplicate: invite already sent"))
               
         other.invites.addToSet(inviter_id)
         other.save (err) ->
            return next(new MongoError(err)) if err
            res.json status: "success"

            # send push
            unless process.env.NODE_TESTING
               parse.sendPushNotification 
                  channels: ["user_#{other_id}"]
                  data: 
                     alert: "#{inviter.first_name} #{inviter.last_name} just sent you a Roster Request."
                     event: "invite"
                     title: "Roster Request"
               , (err) ->
                  console.error "Failed to send invite push: ", err if err

app.put "/v1/users/:user_id/verified", auth.hofStatus, (req, res, next) ->
   verified = req.body.verified or null
   user_id = req.params.user_id

   async.parallel
      user: (done) -> User.update {_id: user_id}, { verified: verified }, done
      profiles: (done) -> TeamProfile.update {user_id: user_id}, {verified: verified}, {multi:true}, done
      huddles: (done) ->
         Huddle.update { "owner_user_id": user_id }
         , { "owner_verified": verified }
         , { multi: true }
         , done
   , (err, results) ->
      return next(new MongoError(err)) if err
      return next((new InvalidArgumentError("Invalid: user_id"))) if results.user == 0
   
      res.send status: "success"
      
      # Update replies after the fact
      Huddle.find { "replies.owner_user_id": user_id }, "replies", (err, huddles) ->
         return if err or not (huddles?.length > 0)
         q = async.queue (huddle, callback) ->
            for reply in huddle.replies
               if user_id == reply.owner_user_id.toString()
                  reply.owner_verified = verified 
            huddle.save(callback)
         , 10

         q.push(huddle) for huddle in huddles



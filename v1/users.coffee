express = require "express"
rest = require "request"
auth = require "../common/middleware/authenticate"
TeamProfile = require "../common/models/TeamProfile"
Team = require "../common/models/Team"
User = require "../common/models/User"
MongoError = require "../common/errors/MongoError"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"
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
            parse.sendPushNotification 
               channels: ["user_#{other_id}"]
               data: 
                  alert: "#{inviter.first_name} #{inviter.last_name} just sent you a Roster Request."
                  event: "invite"
            , (err) ->
               console.error "Failed to send invite push: ", err if err
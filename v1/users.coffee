express = require "express"
rest = require "request"
auth = require "../common/middleware/authenticate"
TeamProfile = require "../common/models/TeamProfile"
Team = require "../common/models/Team"
User = require "../common/models/User"
MongoError = require "../common/errors/MongoError"

app = module.exports = express()

app.post "/v1/users/:user_id/invite", auth.rookie, (req, res, next) ->
   other_id = req.params.user_id
   inviter_id = req.body.inviter_user_id

   User
   .update { _id: other_id }, { $addToSet: { invites: inviter_id }}, (err) ->
      return next(new MongoError(err)) if err
      res.json status: "success"
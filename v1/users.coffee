express = require "express"
rest = require "request"
auth = require "../common/middleware/authenticate"
TeamProfile = require "../common/models/TeamProfile"
Team = require "../common/models/Team"
User = require "../common/models/User"
MongoError = require "../common/errors/MongoError"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"

app = module.exports = express()

app.get "/v1/users/:user_id", auth.rookieStatus, (req, res, next) ->
   return next()
   # user_id = req.params.user_id
   # is_friend_of = req.query.is_friend_of

   # User
   # .findById(user_id)
   # .lean()
   # .exec (err, user) ->
   #    return next(new MongoError(err)) if err
   #    return next(new InvalidArgumentError("Invalid: user_id")) unless user

   #    user.

app.post "/v1/users/:user_id/invite", auth.rookieStatus, (req, res, next) ->
   other_id = req.params.user_id
   inviter_id = req.body.inviter_user_id

   User
   .update { _id: other_id }, { $addToSet: { invites: inviter_id }}, (err) ->
      return next(new MongoError(err)) if err
      res.json status: "success"
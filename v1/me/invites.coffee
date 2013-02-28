express = require "express"
auth = require "../../common/middleware/authenticate"
MongoError = require "../../common/errors/MongoError"
InvalidArgumentError = require "../../common/errors/InvalidArgumentError"
TeamProfile = require "../../common/models/TeamProfile"
User = require "../../common/models/User"
async = require "async"

app = module.exports = express()

# Get all invites for this user
app.get "/v1/me/invites", auth.rookieStatus, (req, res, next) ->
   me_id = req.user._id

   User.findById req.user._id, "invites", (err, user) ->
      return next(new MongoError(err)) if err

      TeamProfile
      .aggregate { $match: { user_id: { $in: user.invites }}}
      , { $group: { _id: "$user_id", "name": {$first: "$name"}, "profile_image_url": {$first: "$profile_image_url"}, "verified":{$first:"$verified"}, "teams": {$addToSet: "$team_name"}}}
      , (err, profiles) ->
         return next(new MongoError(err)) if err
         res.json profiles
      
# Accept an invite
app.post "/v1/me/invites", auth.rookieStatus, (req, res, next) ->
   other_user_id = req.body.user_id
   return next(new InvalidArgumentError("Required: user_id")) unless other_user_id

   User.findById req.user._id, (err, user) ->
      return next(new MongoError(err)) if err
      user.acceptInvite other_user_id, (err) ->
         return next(new MongoError(err)) if err
         res.json status: "success"

deleteInvite = (req, res, next) ->
   other_user_id = req.body.user_id
   return next(new InvalidArgumentError("Required: user_id")) unless other_user_id
   
   User
   .update { _id: req.user._id }, { $pull: { invites: other_user_id }}
   , (err, data) ->
      return next(new MongoError(err)) if err
      if data == 1 
         res.json status: "success"
      else
         next(new InvalidArgumentError("Invalid: user_id not in invite list"))

app.del "/v1/me/invites", auth.rookieStatus, deleteInvite
app.post "/v1/me/invites/delete", auth.rookieStatus, deleteInvite


express = require "express"
auth = require "../../common/middleware/authenticate"
MongoError = require "../../common/errors/MongoError"
InvalidArgumentError = require "../../common/errors/InvalidArgumentError"
User = require "../../common/models/User"
async = require "async"

app = module.exports = express()

# Get all invites for this user
deleteFriendship = (req, res, next) ->
   other_user_id = req.params.user_id
   return next(new InvalidArgumentError("Invalid: user_id")) unless other_user_id
   
   User.findById req.user._id, "friends", (err, user) ->
      return next(new MongoError(err)) if err
      user.removeFriend other_user_id, (err) ->
         return next(err) if err
         res.json status: "success"

app.del "/v1/me/friends/:user_id", auth.rookieStatus, deleteFriendship
app.post "/v1/me/friends/:user_id/delete", auth.rookieStatus, deleteFriendship


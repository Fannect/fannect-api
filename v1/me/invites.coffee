express = require "express"
authenticate = require "../common/middleware/authenticate"
MongoError = require "../common/errors/MongoError"

app = module.exports = express()

# Get all invites for this user
app.get "/v1/me/invites", authenticate, (req, res, next) ->
   UserProfile
   .find({ user_id: { $in: req.user.invites } })
   .select("name team_name profile_image_url")
   .exec (err, data) ->
      return next(new MongoError(err))
      res.json data

# Create invite for this user
app.post "/v1/me/invites/:user"


app.


/v1/users/:user_id/invite
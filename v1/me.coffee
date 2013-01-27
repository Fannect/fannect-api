express = require "express"
rest = require "request"
mongoose = require "mongoose"
User = require "../common/models/User"
TeamProfile = require "../common/models/TeamProfile"
auth = require "../common/middleware/authenticate"
redis = require("../common/utils/redis").client
MongoError = require "../common/errors/MongoError"
async = require "async"

app = module.exports = express()

# Get this user
app.get "/v1/me", auth.rookieStatus, (req, res, next) ->
   res.json req.user

# Update this user
app.put "/v1/me", auth.rookieStatus, (req, res, next) ->
   b = req.body
   
   async.parallel [
      (done) ->
         User.update { _id: req.user._id },
            first_name: b.first_name
            last_name: b.last_name
         , done
      (done) ->
         # Update name in all TeamProfiles
         if b.first_name or b.last_name
            name = "#{b.first_name or req.user.first_name} #{b.last_name or req.user.last_name}"
            TeamProfile.update { user_id: req.user._id },
               { name: name },
               { multi: true } 
            , done
   ], (err, data) ->
      return next(new MongoError(err)) if err
      res.json status: "success"

app.use require "./me/games"
app.use require "./me/invites"
app.use require "./me/teams"
express = require "express"
auth = require "../../common/middleware/authenticate"
MongoError = require "../../common/errors/MongoError"
RestError = require "../../common/errors/RestError"
InvalidArgumentError = require "../../common/errors/InvalidArgumentError"
TeamProfile = require "../../common/models/TeamProfile"
User = require "../../common/models/User"
async = require "async"
request = require "request"

app = module.exports = express()

# Get all invites for this user
app.get "/v1/me/facebook/friends", auth.rookieStatus, (req, res, next) ->
   
   if not (token = req.query.facebook_access_token)
      return next(new InvalidArgumentError("Required: facebook_access_token"))

   friends = []
   starting_url = "https://graph.facebook.com/me/friends?fields=id,name,installed?access_token=#{token}"

   getFriends = (url, done) ->
      request
         url: url
      , (err, resp, body) ->
         return next(new RestError(err)) if err
         friends.push(friend) if friend?.installed for friend in body.data if body?.data
         if body?.paging?.next? then getFriends(body.paging.next, done)
         else done()

   getFriends starting_url, () ->
      res.json friends
            
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
   starting_url = "https://graph.facebook.com/me/friends?fields=id,name,installed&access_token=#{token}"
   user_id = req.user._id

   # find friends 
   User
   .find({ $or: [{friends: user_id}, {invites: user_id} ], facebook: {$exists:true} })
   .select("facebook")
   .exec (err, exclude = []) ->
      return next(new MongoError(err)) if err
      getFriends = (url, done) ->
         request
            url: url
         , (err, resp, body) ->
            return next(new RestError(err)) if err
            body = JSON.parse(body)
            return next(new RestError(400, body?.error?.type, body?.error?.message)) if body?.error
            
            if body?.data
               for friend in body.data 
                  if friend?.installed
                     skip = false
                     for person in exclude
                        if person?.facebook?.id == friend.id
                           skip = true
                           break
                     # Add to list if not in exclude list
                     friends.push(friend) unless skip

            if body?.paging?.next? then getFriends(body.paging.next, done)
            else done()

      getFriends starting_url, () ->
         res.json friends

app.post "/v1/me/facebook/invite", auth.rookieStatus, (req, res, next) ->
   facebook_user_ids = req.body.facebook_user_ids
   return next(new InvalidArgumentError("Required: facebook_user_ids")) unless facebook_user_ids

   facebook_user_ids = [facebook_user_ids] if typeof facebook_user_ids == "string"

   User.find { "facebook.id": {$in:facebook_user_ids} }, "id", (err, users) ->
      return next(new MongoError(err)) if err
      q = async.queue (user, callback) ->
         User.sendInvite(req.user, user._id, callback)
      , 10

      q.push(user) for user in users
      q.drain = (err) ->
         return next(new RestError(err)) if err
         res.json status: "success"

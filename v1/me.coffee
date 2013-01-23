express = require "express"
rest = require "request"
mongoose = require "mongoose"
User = require "../common/models/User"
authenticate = require "../common/middleware/authenticate"
redis = require("../common/utils/redis").client

app = module.exports = express()

# Get this user
app.get "/v1/me", authenticate, (req, res, next) ->
   res.json req.user

# Update this user
app.put "/v1/me", authenticate, (req, res, next) ->
   User
   .findOne({ "_id": req.user._id })
   .select("_id email first_name last_name refresh_token birth gender")
   .exec (err, user) ->
      return next(err) if err

      b = req.body
      user.first_name = b.first_name if b.first_name
      user.last_name = b.last_name if b.last_name
      # user.birth = b.birth if b.birth
      # user.gender = b.gender if b.gender

      user.save (err, user) ->
         return next(err) if err

         redis.set req.query.access_token, user.toJSON(), (err, result) ->
            return next(err) if err

            redis.expire req.query.access_token, 1800
            req.json
               status: "success"






   console.log req.body


# app.post "/v1/me", (req, res, next) ->
#    if not body = req.body then next "Missing body"

#    User.create
#       email: body.email
#       password: crypt.hashPassword body.password
#       first_name: body.first_name
#       last_name: body.last_name
#       refresh_token: crypt.generateRefreshToken()
#    , (err, user) ->
#       if err then next err
#       else res.json user

app.use require "./me/games"
app.use require "./me/invites"
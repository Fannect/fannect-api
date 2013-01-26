express = require "express"
auth = require "../../common/middleware/authenticate"
MongoError = require "../../common/errors/MongoError"
InvalidArgumentError = require "../../common/errors/InvalidArgumentError"
TeamProfile = require "../../common/models/TeamProfile"
User = require "../../common/models/User"
async = require "async"

app = module.exports = express()

# Get all invites for this user
app.get "/v1/me/invites", auth.rookie, (req, res, next) ->
   me_id = req.user._id

   User.findById req.user._id, (err, user) ->
      return next(new MongoError(err)) if err

      TeamProfile
      .aggregate { $match: { user_id: { $in: user.invites }}}
      , { $group: { _id: "$user_id", "name": {$first: "$name"}, "profile_image_url": {$first: "$profile_image_url"}, "teams": {$addToSet: "$team_name"}}}
      , (err, profiles) ->
         return next(new MongoError(err)) if err
         res.json profiles
      
# Accept an invite
app.post "/v1/me/invites", auth.rookie, (req, res, next) ->
   other_user_id = req.body.user_id
   return next(new InvalidArgumentError("Required: user_id")) unless other_user_id

   User.findById req.user._id, (err, user) ->
      return next(new MongoError(err)) if err
      user.acceptInvite other_user_id, (err) ->
         return next(new MongoError(err)) if err
         res.json status: "success"



   # async.parallel {
   #    user: (done) -> User.findOne { _id: req.user.id }, "_id invites friends", done
   #    other_user: (done) -> User.findOne { _id: other_user_id }, "_id friends", done
   # }, (err, data) ->
   #    return next(new MongoError(err))

   #    user = data.user
   #    other_user = data.other_user

   #    # Check if user has invite with other user
   #    if other_user._id in user.invites
   #       user.invites.splice(user.invites.indexOf(other_user._id), 1)
   #       user.friends.push other_user._id
   #       other_user.friends.push user._id

   #    async.parallel {
   #       this_team_profiles: (done) -> 
   #          TeamProfile.find { user_id: user._id }, "_id team_key friends", done
   #       other_team_profiles: (done) ->
   #          TeamProfile.find { user_id: other_user._id }, "_id team_key friends", done
   #    }, (err, profiles) ->
   #       return next(new MongoError(err))

   #       this_team_profiles = profiles.this_team_profiles
   #       other_team_profiles = profiles.other_team_profiles

   #       updated = [ user.save, other_user.save ]

   #       for this_profile in this_team_profiles
   #          for other_profile in other_team_profiles
   #             if this_profile.team_key == other_profile.team_key
   #                this_profile.friends.push other_profile._id
   #                other_profile.friends.push this_profile._id
   #                updated.push this_profile.save
   #                updated.push other_profile.save
   #                break

   #    async.parallel updated, (err) ->
   #       return next(new MongoError(err)) if err
   #       res.json
   #          status: "success"

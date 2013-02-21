express = require "express"
auth = require "../common/middleware/authenticate"
Group = require "../common/models/Group"
User = require "../common/models/User"
TeamProfile = require "../common/models/TeamProfile"
MongoError = require "../common/errors/MongoError"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"
async = require "async"

app = module.exports = express()

app.get "/v1/groups/:group_id", auth.rookieStatus, (req, res, next) ->
   group_id = req.params.group_id
   return next(new InvalidArgumentError("Invalid: group_id")) if group_id == "undefined"

   Group
   .findById group_id, (err, group) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: group_id")) unless group
      res.json group

app.post "/v1/groups/:group_id/teamprofiles", auth.app.ownerStatus, (req, res, next) ->
   group_id = req.params.group_id
   email = req.body.email
   return next(new InvalidArgumentError("Required: email")) unless email
   return next(new InvalidArgumentError("Invalid: group_id")) if group_id == "undefined"

   Group.findById group_id, (err, group) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: group_id")) unless group

      User.findOne {email: email}, "_id name", (err, user) ->
         return next(new MongoError(err)) if err
         return next(new InvalidArgumentError("Invalid: email")) unless user

         TeamProfile
         .findOne({ user_id: user._id, team_id: group.team_id })
         .select("groups")
         .exec (err, profile) ->
            return next(new MongoError(err)) if err
            return next(new InvalidArgumentError("User does not have a profile for team: #{group.team_name}")) unless profile

            for group in profile.groups
               if group.group_id.toString() == group_id
                  return next(new InvalidArgumentError("User is already a part of group: #{group.name}"))

            profile.groups.addToSet {
               group_id: group._id
               name: group.name
               tags: group.tags
            }

            profile.save (err) ->
               return next(new MongoError(err)) if err
               res.json status: "success"
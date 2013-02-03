mongoose = require "mongoose"
User = require "../../common/models/User"
TeamProfile = require "../../common/models/TeamProfile"
Team = require "../../common/models/Team"
async = require "async"

module.exports =

   load: (obj, cb) ->
      creates = {}

      if obj.users
         creates.users = (done) -> User.create(obj.users, done)

      if obj.teams
         creates.teams = (done) -> Team.create(obj.teams, done)

      if obj.teamprofiles
         creates.teamprofiles = (done) -> TeamProfile.create(obj.teamprofiles, done)

      async.parallel(creates, cb)

   unload: (obj, cb) ->
      user_ids = if obj.users then (u._id for u in obj.users) else []
      team_ids = if obj.teams then (t._id for t in obj.teams) else []
      profile_ids = if obj.teamprofiles then (t._id for t in obj.teamprofiles) else []

      async.parallel [
         (done) -> User.remove({_id: { $in: user_ids }}, done)
         (done) -> Team.remove({_id: { $in: team_ids }}, done)
         (done) -> TeamProfile.remove({user_id: { $in: user_ids }}, done)
         (done) -> TeamProfile.remove({_id: { $in: profile_ids }}, done)
      ], cb



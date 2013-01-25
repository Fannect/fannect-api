User = require "../../common/models/User"
TeamProfile = require "../../common/models/TeamProfile"
Team = require "../../common/models/Team"
async = require "async"

module.exports =

   load: (obj, cb) ->
      creates = {}

      if obj.User
         for u in obj.User
            do (user = u) ->
               creates[user._id] = (done) -> User.create(user, done)

      if obj.TeamProfile
         for tp in obj.TeamProfile
            do (teamProfile = tp) ->
               creates[teamProfile._id] = (done) -> TeamProfile.create(teamProfile, done)

      if obj.Team      
         for t in obj.Team
            do (team = t) ->
               creates[team._id] = (done) -> Team.create(team, done)

      async.parallel(creates, cb)

   unload: (obj, cb) ->
      user_ids = if obj.User then (u._id for u in obj.User if obj.User) else []
      team_profile_ids = if obj.TeamProfile then (pt._id for pt in obj.TeamProfile) else []
      team_ids = if obj.Team then (t._id for t in obj.Team) else []

      async.parallel [
         (done) -> User.remove({_id: { $in: user_ids }}, done)
         (done) -> TeamProfile.remove({_id: { $in: team_profile_ids }}, done)
         (done) -> Team.remove({_id: { $in: team_ids }}, done)
      ], cb
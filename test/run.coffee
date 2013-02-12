require "mocha"
should = require "should"
http = require "http"
request = require "request"
mongoose = require "mongoose"
mockAuth = require "./utils/mockAuthenticate"
async = require "async"
csvParser = require "../common/utils/csvParser"

# Have to do this because mongoose is initialized later
dbSetup = null
Team = null
TeamProfile = null
Stadium = null
User = null

data_standard = require "./res/standard"

process.env.REDIS_URL = "redis://redistogo:f74caf74a1f7df625aa879bf817be6d1@perch.redistogo.com:9203"
process.env.MONGO_URL = "mongodb://admin:testing@linus.mongohq.com:10064/fannect"
process.env.NODE_ENV = "production"

app = require "../controllers/host"

emptyMongo = (done) -> dbSetup.unload data_standard, done
prepMongo = (done) ->
   context = @
   dbSetup.load data_standard, (err, data) ->
      return done(err) if err
      context.db = data 
      context.user = data.users[0]
      done()

describe "Fannect Core API", () ->
   before (done) ->
      context = @
      server = http.createServer(app).listen 0, () ->
         context.host = "http://localhost:#{this.address().port}" 
         dbSetup = require "./utils/dbSetup"
         Team = require "../common/models/Team"
         TeamProfile = require "../common/models/TeamProfile"
         User = require "../common/models/User"
         Stadium = require "../common/models/Stadium"
         dbSetup.unload data_standard, done

   #
   # /v1/me
   #
   describe "/v1/me", () ->
      before prepMongo
      after emptyMongo
      
      describe "GET", () ->
         it "should return this user", (done) ->
            context = @
            request
               url: "#{@host}/v1/me"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body._id.should.equal(context.user._id.toString())
               body.email.should.equal(context.user.email)
               done()

      describe "PUT", () ->
         before (done) ->
            context = @
            request
               url: "#{@host}/v1/me"
               method: "PUT"
               json: { first_name: "Bob" ,last_name: "Van" }
            , (err, resp, body) ->
               return done(err) if err
               context.body = body
               done()

         it "should update user correctly", (done) ->
            context = @
            context.body.status.should.equal("success") 
            User.findById context.user._id, (err, user) ->
               return done(err) if err
               user.first_name.should.equal("Bob")
               user.last_name.should.equal("Van")
               done()

         it "should update user's team profiles correctly", (done) ->
            context = @
            TeamProfile
            .find({ user_id: context.user._id })
            .exec (err, team_profiles) ->
               return done(err) if err
               tp.name.should.equal("Bob Van") for tp in team_profiles
               done()
   
   #
   # /v1/me/teams
   #
   describe "/v1/me/teams", () ->
      before prepMongo
      after emptyMongo

      describe "GET", () ->
         it "should get all team profiles", (done) ->
            request
               url: "#{@host}/v1/me/teams"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.length.should.equal(2)
               done()

      describe "POST", () ->
         before (done) ->
            context = @
            request 
               url: "#{@host}/v1/me/teams"
               method: "POST"
               json: { team_id: "5102b17168a0c8f70c000009" }
            , (err, resp, body) ->
               return done(err) if err
               context.body = body
               done()
         after () -> delete @body

         it "should create a new team profile", () ->
            context = @
            context.body.name.should.equal("Mike Testing")
            context.body.team_key.should.equal("l.ncaa.org.mfoot-t.521")

         it "should add to this user's profile_team list", (done) ->
            context = @
            User.findById context.user._id, "team_profiles", (err, user) ->
               return done(err) if err
               user.team_profiles.should.include(context.body._id)
               done()

         it "should rollover friends from over teams", (done) ->
            context = @
            context.body.friends.should.include("5102b17168a0c8f70c000010")
            TeamProfile.findById "5102b17168a0c8f70c000010", (err, profile) ->
               return done(err) if err
               profile.friends.should.include(context.body._id)
               profile.friends_count.should.equal(profile.friends.length)
               done()

         it "should rollover profile_image_url", () ->
            context = @
            context.body.profile_image_url.should.equal("images/empty_profile.jpg")

         it "should not create a duplicate", (done) ->
            request 
               url: "#{@host}/v1/me/teams"
               method: "POST"
               json: { team_id: "5102b17168a0c8f70c000009" }
            , (err, resp, body) ->
               # return done(err) if err
               body.status.should.equal("fail")
               body.reason.should.equal("duplicate")
               done()

   #
   # /v1/me/teams/[team_profile_id]
   #
   describe "/v1/me/teams/[team_profile_id]", () ->
      before prepMongo
      after emptyMongo

      describe "GET", () ->
         it "should get the team profile", (done) ->
            context = @
            request
               url: "#{context.host}/v1/me/teams/#{context.db.teamprofiles[0]._id}"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.name.should.equal("Mike Testing")
               body.team_id.should.be.ok
               body.user_id.should.be.ok
               body.profile_image_url.should.be.ok
               body.team_name.should.be.ok
               body.points.should.be.ok
               body.shouts.length.should.equal(1)
               done()

      describe "DELETE", () ->
         it "should delete team profile", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000005"
            user_id = "5102b17168a0c8f70c000002"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}"
               method: "DELETE"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.status.should.be.ok

               async.parallel
                  profile: (done) -> 
                     TeamProfile.findById(profile_id, "user_id", done)
                  others: (done) ->
                     TeamProfile.find(friends: profile_id, "friends", done)
                  user: (done) ->
                     User.findById(user_id, "team_profiles", done)
               , (err, result) ->
                  return done(err) if err
                  should.not.exist(result.profile)
                  result.others.should.be.empty
                  result.user.team_profiles.should.not.include(profile_id)
                  done()

   #
   # /v1/me/teams/[team_profile_id]/shouts
   #
   describe "/v1/me/teams/[team_profile_id]/shouts", () ->
      before prepMongo
      after emptyMongo

      describe "POST", () ->
         it "should post new shout", (done) ->
            context = @
            request
               url: "#{context.host}/v1/me/teams/#{context.db.teamprofiles[0]._id}/shouts"
               method: "POST"
               json: shout: "This is my cool new shout!"
            , (err, resp, body) ->
               return done(err) if err
               body.status.should.equal("success")
               request 
                  url: "#{context.host}/v1/me/teams/#{context.db.teamprofiles[0]._id}"
               , (err, resp, body) ->
                  body = JSON.parse(body)
                  body.shouts[0].text.should.equal("This is my cool new shout!")
                  done()

   #
   # /v1/me/invites
   #
   describe "/v1/me/invites", () ->
      before prepMongo
      after emptyMongo  
      describe "GET", () ->
         it "should return all invites", (done) ->
            context = @
            request
               url: "#{context.host}/v1/me/invites"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.length.should.equal(1)
               body[0]._id.should.be.ok
               body[0].name.should.be.ok
               body[0].teams.length.should.equal(2)
               done()
      describe "POST", () ->
         before (done) ->
            context = @
            request
               url: "#{context.host}/v1/me/invites"
               method: "POST"
               json: user_id: "5102b17168a0c8f70c000020"
            , (err, resp, body) ->
               return done(err) if err
               done()

         it "should properly swap user ids", (done) ->
            user_id = "5102b17168a0c8f70c000002"
            other_id = "5102b17168a0c8f70c000020"

            async.parallel
               user: (done) -> User.findById user_id, "friends", done
               other: (done) -> User.findById other_id, "friends", done
            , (err, results) ->
               return done(err) if err
               results.user.friends.should.include(other_id)
               results.other.friends.should.include(user_id)
               done()

         it "should properly swap user profile ids", (done) ->
            user_id = "5102b17168a0c8f70c000002"
            other_id = "5102b17168a0c8f70c000020"
            team_id = "5102b17168a0c8f70c000008"

            async.parallel
               user: (done) -> 
                  TeamProfile.findOne {user_id: user_id, team_id: team_id}, "friends friends_count", done
               other: (done) ->
                  TeamProfile.findOne {user_id: other_id, team_id: team_id}, "friends friends_count", done
            , (err, results) ->
               return done(err) if err
               results.user.friends.should.include(results.other._id)
               results.other.friends.should.include(results.user._id)
               results.user.friends_count.should.equal(results.user.friends.length)
               results.other.friends_count.should.equal(results.other.friends.length)
               done()

         it "should remove user_id from invite list", (done) ->
            user_id = "5102b17168a0c8f70c000002"
            other_id = "5102b17168a0c8f70c000020"

            User.findById user_id, "invites", (err, user) ->
               return done(err) if err
               (other_id in user.invites).should.be.false
               done()

      describe "DELETE", () ->
         it "should delete invite", (done) ->
            context = @
            request
               url: "#{context.host}/v1/me/invites"
               method: "DELETE"
               json: user_id: "5102b17168a0c8f70c000020"
            , (err, resp, body) ->
               return done(err) if err
               done()

   #
   # /v1/me/leaderboard/users/[team_id]
   #               
   describe "/v1/leaderboard/users/[team_id]", () ->
      before prepMongo
      after emptyMongo

      describe "GET", () ->
         it "should return leaderboard for a team", (done) ->
            context = @
            request
               url: "#{context.host}/v1/leaderboard/users/5102b17168a0c8f70c000008"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               (body.length >= 3).should.be.true
               (body[0].points.overall >= body[1].points.overall).should.be.true
               done()

         it "should return friends only leaderboard if friends_only flag", (done) ->
            context = @
            request
               url: "#{context.host}/v1/leaderboard/users/5102b17168a0c8f70c000008?friends_of=5102b17168a0c8f70c000005"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               (body[0].points.overall >= body[1].points.overall).should.be.true
               done()

   #
   # /v1/leaderboard/teams/[team_id]/conference
   #  
   describe "/v1/leaderboard/teams/[team_id]/conference", () ->
      before prepMongo
      after emptyMongo

      describe "GET", () ->
         it "should get leaderboard based on conference", (done) ->
            context = @
            request
               url: "#{context.host}/v1/leaderboard/teams/5102b17168a0c8f70c000008/conference"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.conference_name.should.equal("Big 12 Conference")
               (body.teams[0].points.overall >= body.teams[1].points.overall).should.be.true
               done()

   #
   # /v1/leaderboard/teams/[team_id]/league
   #  
   describe "/v1/leaderboard/teams/[team_id]/league", () ->
      before prepMongo
      after emptyMongo

      describe "GET", () ->
         it "should get leaderboard based on league", (done) ->
            context = @
            request
               url: "#{context.host}/v1/leaderboard/teams/5102b17168a0c8f70c000008/league"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.league_name.should.equal("NCAA Men's Football Division 1A")
               (body.teams[0].points.overall >= body.teams[1].points.overall).should.be.true
               done()
   #
   # /v1/leaderboard/teams/[team_id]/breakdown
   #  
   describe "/v1/leaderboard/teams/[team_id]/breakdown", () ->
      before prepMongo
      after emptyMongo

      describe "GET", () ->
         it "should return points breakdown for team", (done) ->
            context = @
            request
               url: "#{context.host}/v1/leaderboard/teams/5102b17168a0c8f70c000008/breakdown"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.points.overall.should.equal(400)
               body.points.knowledge.should.equal(100)
               body.points.passion.should.equal(250)
               body.points.dedication.should.equal(50)
               done()

   #
   # /v1/leaderboard/teams/[team_id]/custom
   #  
   describe "/v1/leaderboard/teams/[team_id]/custom", () ->
      before prepMongo
      after emptyMongo

      describe "GET", () ->
         it "should return points breakdown for two teams to compare", (done) ->
            context = @
            request
               url: "#{context.host}/v1/leaderboard/teams/5102b17168a0c8f70c000008/custom?team_id=5102b17168a0c8f70c000009"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.length.should.equal(2)
               body[0].points.should.be.ok
               body[1].points.should.be.ok
               done()

   #
   # /v1/teams
   #  
   describe "Uploading teams and stadiums", () ->
         before (done) ->
            async.parallel
               teams: (cb) ->
                  Team.remove { team_key: { $in: [ "testing.team.1", "testing.team.2" ]}}, cb
               stadiums: (cb) ->
                  Stadium.remove {stadium_key: { $in: [ "Boston_College_Alumni_Stadium", "Clemson_Memorial_Stadium"]}}, cb
            , done
         after (done) ->
            async.parallel
               teams: (cb) ->
                  Team.remove { team_key: { $in: [ "testing.team.1", "testing.team.2" ]}}, cb
               stadiums: (cb) ->
                  Stadium.remove {stadium_key: { $in: [ "Boston_College_Alumni_Stadium", "Clemson_Memorial_Stadium"]}}, cb
            , done

         it "should parse csv and upload teams", (done) ->
            csvParser.parseTeams "#{__dirname}/res/test-teams.csv", (err, count) ->
               return done(err) if err
               count.should.equal(2)
               Team.find { team_key: { $in: [ "testing.team.1", "testing.team.2"]}}, (err, teams) ->
                  return done(err) if err
                  teams.length.should.equal(2)
                  done()

         it "should parse csv and upload stadiums", (done) ->
            csvParser.parseStadiums "#{__dirname}/res/test-stadiums.csv", (err, count) ->
               return done(err) if err
               count.should.equal(2)
               Stadium.find {stadium_key: { $in: [ "Boston_College_Alumni_Stadium", "Clemson_Memorial_Stadium"]}}, (err, stadiums) ->
                  return done(err) if err
                  stadiums.length.should.equal(2)
                  done()

         it "should associate team_keys and stadiums", (done) ->
            # Team.find (err, team) ->
            Team.findOne team_key: "testing.team.2", (err, team) ->
               return done(err) if err
               team.stadium.name.should.equal("Clemson Memorial Stadium")
               done()

   #
   # /v1/teams/[team_id]/users
   #
   describe "/v1/teams/[team_id]/users", () ->
      before prepMongo
      after emptyMongo
      describe "GET", () ->
         it "should return users sorted by name", (done) ->
            context = @
            request
               url: "#{context.host}/v1/teams/5102b17168a0c8f70c000008/users"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.length.should.equal(3)
               (body[0].name < body[1].name).should.be.true
               done()

         it "should paginate if skip is supplied", (done) ->
            context = @
            request
               url: "#{context.host}/v1/teams/5102b17168a0c8f70c000008/users"
               qs:
                  limit: 1
                  skip: 1
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.length.should.equal(1)
               body[0].name.should.equal("Mike Testing")
               done()

         it "should only return friends if friends_of is supplied", (done) ->
            context = @
            request
               url: "#{context.host}/v1/teams/5102b17168a0c8f70c000008/users"
               qs:
                  friends_of: "5102b17168a0c8f70c000005"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.length.should.equal(1)
               body[0].name.should.equal("Richard Testing")
               done()

   #
   # /v1/teams/[team_id]/users
   #
   describe "/v1/sports", () ->
      before prepMongo
      after emptyMongo
      describe "GET", () ->
         it "should return all sports", (done) ->
            context = @
            request
               url: "#{context.host}/v1/sports"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               (body.length >= 2).should.be.true
               (body[0].sport_name <= body[1].sport_name).should.be.true
               done()

   #
   # /v1/sports/[sport_key]/leagues
   #
   describe "/v1/sports/[sport_key]/leagues", () ->
      before prepMongo
      after emptyMongo
      describe "GET", () ->
         it "should return all leagues within a sport", (done) ->
            context = @
            request
               url: "#{context.host}/v1/sports/15003000/leagues"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               (body.length >= 1).should.be.true
               body[0].league_key.should.be.ok
               body[0].league_name.should.be.ok
               done()

   #
   # /v1/sports/[sport_key]/leagues/[league_key]/teams
   #
   describe "/v1/sports/[sport_key]/leagues/[league_key]/teams", () ->
      before prepMongo
      after emptyMongo
      describe "GET", () ->
         it "should return teams within a league", (done) ->
            context = @
            request
               url: "#{context.host}/v1/sports/15003000/leagues/l.ncaa.org.mfoot/teams"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               (body.length >= 2).should.be.true
               body[0]._id.should.be.ok
               body[0].mascot.should.be.ok
               body[0].full_name.should.be.ok
               body[0].location_name.should.be.ok
               done()

   #
   # /v1/sports/[sport_key]/teams
   #
   describe "/v1/sports/[sport_key]/teams", () ->
      before prepMongo
      after emptyMongo
      describe "GET", () ->
         it "should get users ", (done) ->
            context = @
            request
               url: "#{context.host}/v1/sports/15003000/teams?q=kansas"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               (body.length >= 2).should.be.true
               body[0]._id.should.be.ok
               body[0].mascot.should.be.ok
               body[0].full_name.should.be.ok
               body[0].location_name.should.be.ok
               (body[0].full_name <= body[1].full_name).should.be.true
               done()

   #
   # /v1/users/[user_id]/invite
   #
   describe "/v1/users/[user_id]/invite", () ->
      before prepMongo
      after emptyMongo
      describe "POST", () ->
         it "create invitation to other users", (done) ->
            context = @
            user_id = "5102b17168a0c8f70c000002"
            other_id = "5102b17168a0c8f70c000003"
            request
               url: "#{context.host}/v1/users/#{other_id}/invite"
               method: "POST"
               json: inviter_user_id: user_id
            , (err, resp, body) ->
               return done(err) if err
               body.status.should.equal("success")
               User.findById other_id, "invites", (err, other) ->
                  other.invites.should.include(user_id)
                  done()      

   #
   # /v1/teamprofiles
   #
   describe "/v1/teamprofiles", () ->
      before prepMongo
      after emptyMongo
      describe "GET", () ->
         it "should get team profile of same team if one exists", (done) ->
            context = @
            user_id = "5102b17168a0c8f70c000020"
            friends_with = "5102b17168a0c8f70c000005"
            request
               url: "#{context.host}/v1/teamprofiles?friends_with=#{friends_with}&user_id=#{user_id}"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.team_id.should.equal("5102b17168a0c8f70c000008")
               body.name.should.be.ok
               done()

         it "should get a team profile if the same team doesn't exist", (done) ->
            context = @
            user_id = "5102b17168a0c8f70c000020"
            friends_with = "5102b17168a0c8f70c000105"
            request
               url: "#{context.host}/v1/teamprofiles?friends_with=#{friends_with}&user_id=#{user_id}"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.team_id.should.equal("5102b17168a0c8f70c000008")
               body.name.should.be.ok
               done()

   #
   # /v1/teamprofiles/[team_profile_id]
   #
   describe "/v1/teamprofiles/[team_profile_id]", () ->
      before prepMongo
      after emptyMongo
      describe "GET", () ->
         it "should get team profile", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000005"
            request
               url: "#{context.host}/v1/teamprofiles/#{profile_id}"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body._id.should.be.ok
               body.user_id.should.be.ok
               body.name.should.be.ok
               body.team_name.should.be.ok
               body.is_college.should.be.ok
               done()
         
         it "should set 'is_friend' = true if users are friends", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000005"
            other_id = "5102b17168a0c8f70c000007"
            request
               url: "#{context.host}/v1/teamprofiles/#{profile_id}?is_friend_of=#{other_id}"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body._id.should.be.ok
               body.user_id.should.be.ok
               body.name.should.be.ok
               body.team_name.should.be.ok
               body.is_friend.should.be.true
               done()

         it "should set 'is_friend' = false if users are not friends", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000005"
            other_id = "5102b17168a0c8f70c000009"
            request
               url: "#{context.host}/v1/teamprofiles/#{profile_id}?is_friend_of=#{other_id}"
               method: "GET"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.is_friend.should.be.false
               done()

   require "./tests/games"
   require "./tests/groups"






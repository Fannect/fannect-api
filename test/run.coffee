require "mocha"
should = require "should"
http = require "http"
request = require "request"
csvTeam = require "../common/utils/csvTeam"
mongoose = require "mongoose"
mockAuth = require "./utils/mockAuthenticate"
async = require "async"

# Have to do this because mongoose is initialized later
dbSetup = null
Team = null
TeamProfile = null
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
               body.length.should.equal(1)
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
            async.series
               db: (done) -> TeamProfile.findById context.db.teamprofiles[0]._id, done
               req: (done) ->
                  request
                     url: "#{context.host}/v1/me/teams/#{context.db.teamprofiles[0]._id}"
                     method: "GET"
                  , (err, resp, body) ->
                     return done(err) if err
                     done null, JSON.parse(body)
            , (err, results) ->
               return done(err) if err
               results.db.toObject().toString().should.equal(results.req.toString())
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
               results.user.friends.should.include(other_id)
               results.other.friends.should.include(user_id)
               done()

         it "should properly swap user profile ids", (done) ->
            user_id = "5102b17168a0c8f70c000002"
            other_id = "5102b17168a0c8f70c000020"
            team_id = "5102b17168a0c8f70c000008"

            async.parallel
               users: (done) -> 
                  TeamProfile.find {user_id: user_id, team_id: team_id}, "friends", done
               others: (done) ->
                  TeamProfile.find {user_id: other_id, team_id: team_id}, "friends", done
            , (err, results) ->
               results.users.length.should.equal(1)
               results.others.length.should.equal(1)
               done()

      describe "DELETE", () ->
         it "should delete invite"

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
               body.length.should.equal(3)
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
               (body[0].points.overall >= body[1].points.overall).should.be.true
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
               (body[0].points.overall >= body[1].points.overall).should.be.true
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
               body.overall.should.equal(400)
               body.knowledge.should.equal(100)
               body.passion.should.equal(250)
               body.dedication.should.equal(50)
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
   describe "/v1/teams", () ->
      describe "GET", () ->
         before (done) ->
            Team.remove { team_key: { $in: [ "testing.team.1", "testing.team.2" ]}}, done
         
         after (done) ->
            Team.remove { team_key: { $in: [ "testing.team.1", "testing.team.2" ]}}, done

         it "should parse csv and upload teams", (done) ->
            csvTeam "#{__dirname}/res/test-teams.csv", (err, count) ->
               return done(err) if err
               count.should.equal(2)
               Team.find { team_key: { $in: [ "testing.team.1", "testing.team.2"]}}, (err, teams) ->
                  return done(err) if err
                  teams.length.should.equal(2)
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
               body[0].nickname.should.be.ok
               body[0].abbreviation.should.be.ok
               done()

   #
   # /v1/users/[user_id]/invite
   #
   describe "/v1/users/[user_id]/invite", () ->
      before prepMongo
      after emptyMongo
      describe "POST", () ->
         it "create invitation to other users", (done) ->
            user_id = "5102b17168a0c8f70c000002"
            other_id = "5102b17168a0c8f70c000003"
            context = @
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

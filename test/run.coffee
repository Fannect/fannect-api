require "mocha"
should = require "should"
http = require "http"
request = require "request"
csvTeam = require "../common/utils/csvTeam"
mongoose = require "mongoose"
mockAuth = require "./utils/mockAuthenticate"

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

   describe "/v1/me", () ->
      before (done) ->
         context = @
         dbSetup.load data_standard, (err, data) ->
            return done(err) if err
            context.db = data 
            context.user = data.users[0]
            done()

      after (done) -> dbSetup.unload data_standard, done
      
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


   describe "/v1/me/teams", () ->
      before (done) ->
         context = @
         dbSetup.load data_standard, (err, data) ->
            return done(err) if err
            context.db = data 
            context.user = data.users[0]
            done()

      after (done) -> dbSetup.unload data_standard, done

      describe "GET", () ->
         it "should get all team profiles", (done) ->
            request
               url: "#{@host}/v1/me/teams"
               method: "GET"
            , (err, resp, team_profiles) ->
               return done(err) if err
               team_profiles = JSON.parse(team_profiles)
               team_profiles.length.should.equal(1)
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

   # describe "/v1/me/teams/[team_profile_id]", () ->
   #    before (done) ->
   #       context = @
   #       dbSetup.load data_standard, (err, data) ->
   #          return done(err) if err
   #          context.db = data 
   #          context.user = data.users[0]
   #          done()

   #    after (done) -> dbSetup.unload data_standard, done

   #    describe "GET", () ->

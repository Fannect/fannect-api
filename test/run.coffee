require "mocha"
should = require "should"
http = require "http"
request = require "request"
Team = require "../common/models/Team"
csvTeam = require "../common/utils/csvTeam"
mongoose = require "mongoose"
mockAuth = require "./utils/mockAuthenticate"

# Have to do this because mongoose is initialized later
dbSetup = null

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
         done()

         # dbSetup.unload data_standard, (err) ->
         #    done(err) if err
            # dbSetup.load data_standard, (err) ->
            #    console.log "ERRORS", err
            #    done()


   describe "/v1/me", () ->
      describe "GET", () ->
         before (done) ->
            context = @
            dbSetup.load data_standard, (err, data) ->
               return done(err) if err
               context.db = data 
               context.user = data["5102b17168a0c8f70c000002"]
               done()

         after (done) -> dbSetup.unload data_standard, done

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

   # describe "/v1/teams", () ->
   #    before (done) ->
   #       Team.remove { team_key: { $in: [ "testing.team.1", "testing.team.2" ] } }, done

   #    it "should parse csv and upload teams", (done) ->
   #       csvTeam "#{__dirname}/res/test-teams.csv", (err, count) ->
   #          if err then
   #          return done(err) if err
   #          count.should.equal(2)
   #          Team.find { team_key: { $in: [ "testing.team.1", "testing.team.2" ] } }, (err, teams) ->
   #             return done(err) if err
   #             teams.length.should.equal(2)
   #             done()

   # describe "/v1/users/invite", () ->
   #    describe "POST", () ->
   #       it "should add invite", (done) ->
   #          console.log auth.toString()

   #          context = @
   #          request
   #             url: "#{@host}/v1/users/invite"
   #             method: "POST"
   #             json: user_id: "testing1"
   #          , (err, resp, body) ->
   #             console.log body

currentUser = null

mockAuth = () ->
   auth = passthrough
   auth.sub = passthrough
   auth.starter = passthrough
   auth.allstar = passthrough
   auth.mvp = passthrough
   auth.hof = passthrough

passthrough = (req, res, next) ->
   req.user = currentUser
   next()

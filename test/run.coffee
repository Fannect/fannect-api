require "mocha"
require "./mockAuthenticate"
should = require "should"
http = require "http"
request = require "request"
mongoose = require "mongoose"
Team = require "../common/models/Team"
csvTeam = require "../common/utils/csvTeam"

process.env.REDIS_URL = "redis://redistogo:f74caf74a1f7df625aa879bf817be6d1@perch.redistogo.com:9203"
process.env.MONGO_URL = "mongodb://admin:testing@linus.mongohq.com:10064/fannect"
# process.env.MONGO_URL = "mongodb://blakevanlan:vanlan14@ds037817.mongolab.com:37817/fannect-dev"
process.env.NODE_ENV = "production"

app = require "../controllers/host"

describe "Fannect Core API", () ->
   before (done) ->
      context = @
      server = http.createServer(app).listen 0, () ->
         context.host = "http://localhost:#{this.address().port}" 
         done()

   # describe "/v1/me", () ->

   #    describe "GET", () ->
   #       it "should return this user", () ->


   describe "/v1/teams", () ->
      before (done) ->
         Team.remove { team_key: { $in: [ "testing.team.1", "testing.team.2" ] } }, done

      it "should parse csv and upload teams", (done) ->
         csvTeam "#{__dirname}/res/test-teams.csv", (err, count) ->
            if err then
            return done(err) if err
            count.should.equal(2)
            Team.find { team_key: { $in: [ "testing.team.1", "testing.team.2" ] } }, (err, teams) ->
               return done(err) if err
               teams.length.should.equal(2)
               done()

   describe "/v1/teams", () ->

      it "should"

         # context = @
         # request 
         #    url: @host
            
         # , (err, res) ->
         #    done(err) if err
         #    res.status.should.equal("success")
         #    res.count.should.equal(2)
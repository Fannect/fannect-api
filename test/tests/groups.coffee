require "mocha"
should = require "should"
request = require "request"
mongoose = require "mongoose"
async = require "async"

data_games = require "../res/game-data"

dbSetup = null
TeamProfile = null
Stadium = null
User = null
Team = null
Group = null

describe.only "Groups", () ->
   before (done) ->
      dbSetup = require "../utils/dbSetup"
      Team = require "../../common/models/Team"
      User = require "../../common/models/User"
      Group = require "../../common/models/Group"
      TeamProfile = require "../../common/models/TeamProfile"
      dbSetup.unload data_games, done
      
   #
   # /v1/teams/[team_id]/groups
   #
   describe "/v1/teams/[team_id]/groups", () ->
      before (done) -> dbSetup.load data_games, done
      after (done) -> dbSetup.unload data_games, done

      describe "GET", () ->
         it "should return groups with correct tags and team", (done) ->
            context = @
            team_id = "5102b17168a0c8f70c000008"
            request
               url: "#{context.host}/v1/teams/#{team_id}/groups"
               qs: { tags: "tag one, tag two" }
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.length.should.equal(1)
               done()

      describe "POST", () ->
         it "should create a group with correct team_id", (done) ->
            context = @
            team_id = "51084c08f71f41521a7b1ef2"
            async.series
               first: (done) -> 
                  request
                     url: "#{context.host}/v1/teams/#{team_id}/groups"
                     method: "POST"
                     json: { name: "Test group!", tags: "testing one, testing two" }
                  , (err, resp, body) ->
                     return done(err) if err
                     done(null, body)
               second: (done) -> Group.find(team_id: team_id, done)
            , (err, results) ->
               return done(err) if err
               results.first.status.should.equal("success")
               results.second.length.should.equal(1)
               results.second[0].name.should.equal("Test group!")
               done()

   #
   # /v1/groups/[group_id]
   #
   describe "/v1/groups/[group_id]", () ->
      before (done) -> dbSetup.load data_games, done
      after (done) -> dbSetup.unload data_games, done

      describe "GET", () ->
         it "should group with matching group_id", (done) ->
            context = @
            group_id = "5102b17168a0c8f71c000019"
            request
               url: "#{context.host}/v1/groups/#{group_id}"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.sport_key.should.equal("15003000")
               body.sport_name.should.equal("American Football")
               body.points.should.be.ok
               done()

   #
   # /v1/groups/[group_id]/teamprofiles
   #
   describe "/v1/groups/[group_id]/teamprofiles", () ->
      before (done) -> dbSetup.load data_games, done
      after (done) -> dbSetup.unload data_games, done

      describe "POST", () ->
         it "should group with matching group_id", (done) ->
            context = @
            group_id = "5102b17168a0c8f71c000019"
            profile_id = "5102b17168a0c8f70c001005"
            request
               url: "#{context.host}/v1/groups/#{group_id}/teamprofiles"
               method: "POST"
               json: email: "testing1@fannect.me"
            , (err, resp, body) ->
               return done(err) if err
               body.status.should.equal("success")
               TeamProfile.findById profile_id, "groups", (err, profile) ->
                  return done(err) if err
                  profile.groups.length.should.equal(1)
                  profile.groups[0].name.should.equal("Some Group")
                  profile.groups[0].tags.length.should.equal(2)
                  done()




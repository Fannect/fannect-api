require "mocha"
should = require "should"
request = require "request"
mongoose = require "mongoose"
async = require "async"

data_huddle = require "../res/huddle-data"

dbSetup = null
TeamProfile = null
Stadium = null
User = null
Team = null
Huddle = null

describe "Huddles", () ->
   before (done) ->
      dbSetup = require "../utils/dbSetup"
      Team = require "../../common/models/Team"
      User = require "../../common/models/User"
      Huddle = require "../../common/models/Huddle"
      TeamProfile = require "../../common/models/TeamProfile"
      dbSetup.unload data_huddle, done
      
   #
   # /v1/teams/[team_id]/huddles
   #
   describe "/v1/teams/:team_id/huddles", () ->

      describe "GET", () ->
         before (done) -> dbSetup.load data_huddle, done
         after (done) -> dbSetup.unload data_huddle, done

         it "should search huddles", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000005"
            team_id = "5102b17168a0c8f70c000008"
            user_id = "5102b17168a0c8f70c000002"

            request
               url: "#{context.host}/v1/teams/#{team_id}/huddles"
               qs:
                  skip: 0
                  limit: 1
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.length.should.equal(1)
               body[0].team_id.should.equal(team_id)
               done()

         it "should search huddles and include any", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000005"
            team_id = "5102b17168a0c8f70c000008"
            user_id = "5102b17168a0c8f70c000002"

            request
               url: "#{context.host}/v1/teams/#{team_id}/huddles"
               qs:
                  skip: 0
                  created_by: "any"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.length.should.equal(2)
               body[0]._id.toString().should.equal("513526fec16e8ec75f00009b")
               done()

         it "should search huddles and filter by roster", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000005"
            team_id = "5102b17168a0c8f70c000008"
            user_id = "5102b17168a0c8f70c000002"

            request
               url: "#{context.host}/v1/teams/#{team_id}/huddles"
               qs:
                  skip: 0
                  created_by: "roster"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.length.should.equal(1)
               body[0]._id.toString().should.equal("513526fec16e8ec75f00000a")
               done()

      describe "POST", () ->
         before (done) -> dbSetup.load data_huddle, done
         after (done) -> dbSetup.unload data_huddle, done

         it "should create huddle", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000005"
            team_id = "5102b17168a0c8f70c000008"
            user_id = "5102b17168a0c8f70c000002"
             
            request
               url: "#{context.host}/v1/teams/#{team_id}/huddles"
               method: "POST"
               json: { 
                  team_profile_id: profile_id
                  topic: "Here's a test topic"
                  content: "Here is some fake content"
               }
            , (err, resp, body) ->
               return done(err) if err
               body.team_id.toString().should.equal(team_id)
               body.team_name.should.equal("Kansas St. Wildcats")
               body.owner_user_id.toString().should.equal(user_id)
               body.owner_id.toString().should.equal(profile_id)
               body.owner_verified.should.equal("Testing_Squad")
               body.topic.should.equal("Here's a test topic")
               body.replies.length.should.equal(1)
               body.reply_count.should.equal(1)
               body.replies[0].owner_id.toString().should.equal(profile_id)
               body.replies[0].owner_name.should.equal("Mike Testing")
               body.replies[0].content.should.equal("Here is some fake content")
               done()

         it "should create huddle with associated team", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000005"
            team_id = "5102b17168a0c8f70c000008"
            user_id = "5102b17168a0c8f70c000002"
      
            request
               url: "#{context.host}/v1/teams/#{team_id}/huddles"
               method: "POST"
               json: { 
                  team_profile_id: profile_id
                  topic: "Here's a test topic"
                  content: "Here is some fake content"
                  include_teams: ["51038413f71f44551a7b172a"]
                  include_league: true
                  include_conference: true
               }
            , (err, resp, body) ->
               return done(err) if err
               
               # Ensure the same info is still there
               body.team_id.toString().should.equal(team_id)
               body.team_name.should.equal("Kansas St. Wildcats")
               body.owner_user_id.toString().should.equal(user_id)
               body.owner_id.toString().should.equal(profile_id)
               body.topic.should.equal("Here's a test topic")
               body.replies.length.should.equal(1)
               body.reply_count.should.equal(1)
               body.replies[0].owner_id.toString().should.equal(profile_id)
               body.replies[0].owner_name.should.equal("Mike Testing")
               body.replies[0].content.should.equal("Here is some fake content")
               
               body.tags.length.should.equal(3)
               body.tags[0].type.should.equal("team")
               body.tags[1].type.should.equal("league")
               body.tags[1].name.should.equal("NCAA Men's Football Division 1A")
               body.tags[2].type.should.equal("conference")
               body.tags[2].name.should.equal("Big 12 Conference")

               done()
   #
   # /v1/huddles/[huddle_id]
   #
   describe "/v1/huddles/:huddle_id", () ->

      describe "GET", () ->
         before (done) -> dbSetup.load data_huddle, done
         after (done) -> dbSetup.unload data_huddle, done

         it "should retrieve huddle", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000024"
            team_id = "5102b17168a0c8f70c000444"
            user_id = "5102b17168a0c8f70c000020"
            huddle_id = "513526fec16e8ec75f000828"

            request
               url: "#{context.host}/v1/huddles/#{huddle_id}"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body._id.toString().should.equal(huddle_id)
               body.owner_user_id.toString().should.equal("5102b17168a0c8f70c000003")
               body.owner_name.should.be.ok
               body.topic.should.be.ok
               body.views.should.equal(5)
               done()

   #
   # /v1/huddles/[huddle_id]/replies
   #
   describe "/v1/huddles/:huddle_id/replies", () ->

      describe "GET", () ->
         before (done) -> dbSetup.load data_huddle, done
         after (done) -> dbSetup.unload data_huddle, done

         it "should retrieve single reply", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000024"
            team_id = "5102b17168a0c8f70c000444"
            user_id = "5102b17168a0c8f70c000020"
            huddle_id = "513526fec16e8ec75f000828"

            request
               url: "#{context.host}/v1/huddles/#{huddle_id}/replies"
               qs: skip: 1, limit: 1
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.meta.count.should.be.ok
               body.meta.limit.should.be.ok
               body.meta.skip.should.be.ok
               should.exist(body.meta.reverse)
               body.replies[0]._id.toString().should.equal("5102b17168a0c8f70c000025")
               body.replies[0].owner_name.should.equal("Bob Testing")
               done()

      describe "POST", () ->
         before (done) -> dbSetup.load data_huddle, done
         after (done) -> dbSetup.unload data_huddle, done

         it "should create reply", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000024"
            team_id = "5102b17168a0c8f70c000444"
            user_id = "5102b17168a0c8f70c000020"
            huddle_id = "513526fec16e8ec75f000828"

            request
               url: "#{context.host}/v1/huddles/#{huddle_id}/replies"
               method: "POST"
               json: 
                  team_profile_id: profile_id
                  content: "Here is some kind of reply!"
            , (err, resp, body) ->
               return done(err) if err
               body.meta.count.should.equal(4)
               Huddle.findById huddle_id, (err, huddle) ->
                  return done(err) if err
                  huddle.reply_count.should.equal(huddle.replies.length)
                  reply = huddle.replies[huddle.replies.length-1]
                  reply.owner_id.toString().should.equal("5102b17168a0c8f70c000024")
                  reply.content.should.equal("Here is some kind of reply!")
                  reply.owner_verified.should.equal("Fannect_Squad")
                  done()

   #
   # /v1/huddles/[huddle_id]/ratings
   #
   describe "/v1/huddles/:huddle_id/ratings", () ->

      describe "POST", () ->
         before (done) -> dbSetup.load data_huddle, done
         after (done) -> dbSetup.unload data_huddle, done

         it "should create reply", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000024"
            team_id = "5102b17168a0c8f70c000444"
            user_id = "5102b17168a0c8f70c000020"
            huddle_id = "513526fec16e8ec75f000828"

            request
               url: "#{context.host}/v1/huddles/#{huddle_id}/rating"
               method: "POST"
               json: 
                  team_profile_id: profile_id
                  rating: 3
            , (err, resp, body) ->
               return done(err) if err
               body.status.should.equal("success")
               body.rating_count.should.equal(3)
               Huddle.findById huddle_id, (err, huddle) ->
                  return done(err) if err
                  huddle.rating_count.should.equal(body.rating_count)
                  done()

         it "should create reply", (done) ->
            context = @
            profile_id = "513526fec16e9ec75f007777"
            team_id = "5102b17168a0c8f70c000444"
            user_id = "5102b17168a0c8f70c000020"
            huddle_id = "513526fec16e8ec75f000828"

            request
               url: "#{context.host}/v1/huddles/#{huddle_id}/rating"
               method: "POST"
               json: 
                  team_profile_id: profile_id
                  rating: 3
            , (err, resp, body) ->
               return done(err) if err
               body.status.should.equal("fail")
               done()


                  
   

require "mocha"
should = require "should"
request = require "request"
mongoose = require "mongoose"
async = require "async"

data_highlight = require "../res/highlight-data"

dbSetup = null
TeamProfile = null
Stadium = null
User = null
Team = null
Huddle = null
Highlight = null

describe "Highlights", () ->
   before (done) ->
      dbSetup = require "../utils/dbSetup"
      Team = require "../../common/models/Team"
      User = require "../../common/models/User"
      Huddle = require "../../common/models/Huddle"
      TeamProfile = require "../../common/models/TeamProfile"
      Highlight = require "../../common/models/Highlight"
      dbSetup.unload data_highlight, done
      
   #
   # /v1/teams/[team_id]/highlights
   #
   describe "/v1/teams/:team_id/highlights", () ->

      describe "GET", () ->
         before (done) -> dbSetup.load data_highlight, done
         after (done) -> dbSetup.unload data_highlight, done

         it "should search highlights", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000005"
            team_id = "5102b17168a0c8f70c000008"
            user_id = "5102b17168a0c8f70c000002"

            request
               url: "#{context.host}/v1/teams/#{team_id}/highlights"
               qs:
                  skip: 0
                  limit: 1
                  create_by: "team"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.length.should.equal(1)
               body[0].team_id.should.equal(team_id)
               done()

      describe "POST", () ->
         before (done) -> dbSetup.load data_highlight, done
         after (done) -> dbSetup.unload data_highlight, done

         it "should create highlight", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000005"
            team_id = "5102b17168a0c8f70c000008"
            user_id = "5102b17168a0c8f70c000002"
             
            request
               url: "#{context.host}/v1/teams/#{team_id}/highlights"
               method: "POST"
               json: 
                  image_url: "http://fannect.me/fake-image.jpg"
                  caption: "Here is a caption!"
                  game_type: "gameday_pics"
            , (err, resp, body) ->
               return done(err) if err
               body.team_id.toString().should.equal(team_id)
               body.team_name.should.equal("Kansas St. Wildcats")
               body.owner_user_id.toString().should.equal(user_id)
               body.owner_id.toString().should.equal(profile_id)
               body.owner_verified.should.equal("Testing_Squad")
               body.caption.should.equal("Here is a caption!")
               body.comment_count.should.equal(0)
               body.game_type.should.equal("gameday_pics")
               done()

   #
   # /v1/highlights/[highlight_id]
   #
   describe "/v1/highlights/:highlight_id", () ->

      describe "GET", () ->
         before (done) -> dbSetup.load data_highlight, done
         after (done) -> dbSetup.unload data_highlight, done

         it "should retrieve highlight", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000024"
            team_id = "5102b17168a0c8f70c000444"
            user_id = "5102b17168a0c8f70c000020"
            highlight_id = "513526fec16e8ec75f00000a"

            request
               url: "#{context.host}/v1/highlights/#{highlight_id}"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body._id.toString().should.equal(highlight_id)
               body.owner_user_id.toString().should.equal("5102b17168a0c8f70c000002")
               body.owner_name.should.be.ok
               body.caption.should.equal("My awesome caption")
               should.not.exist(body.up_votes_by)
               should.not.exist(body.down_votes_by)
               body.up_votes.should.equal(10)
               body.down_votes.should.equal(2)
               body.current_vote.should.equal("owner")
               done()

   #
   # /v1/highlights/[highlight_id]/comments
   #
   describe "/v1/highlights/:highlight_id/comments", () ->

      describe "GET", () ->
         before (done) -> dbSetup.load data_highlight, done
         after (done) -> dbSetup.unload data_highlight, done

         it "should retrieve comments", (done) ->
            context = @
            team_id = "5102b17168a0c8f70c000444"
            user_id = "5102b17168a0c8f70c000020"
            highlight_id = "513526fec16e8ec75f00001b"

            request
               url: "#{context.host}/v1/highlights/#{highlight_id}/comments"
               qs: skip: 1, limit: 1
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.meta.count.should.be.ok
               body.meta.limit.should.be.ok
               body.meta.skip.should.be.ok
               should.exist(body.meta.reverse)
               body.comments[0]._id.toString().should.equal("514526fec16e8ec75f000112")
               body.comments[0].owner_name.should.equal("Scott Tester")
               body.comments[0].content.should.equal("Here is some fake content")
               done()

      describe "POST", () ->
         before (done) -> dbSetup.load data_highlight, done
         after (done) -> dbSetup.unload data_highlight, done

         it "should create comment", (done) ->
            context = @
            highlight_id = "513526fec16e8ec75f00001b"
            profile_id = "5102b17168a0c8f70c000005"

            request
               url: "#{context.host}/v1/highlights/#{highlight_id}/comments"
               method: "POST"
               json: 
                  team_profile_id: profile_id
                  content: "Impressive picture..."
            , (err, resp, body) ->
               return done(err) if err
               body.meta.count.should.equal(3)
               Highlight.findById highlight_id, (err, highlight) ->
                  return done(err) if err
                  highlight.comment_count.should.equal(highlight.comments.length)
                  comment = highlight.comments[highlight.comments.length-1]
                  comment.owner_id.toString().should.equal("5102b17168a0c8f70c000005")
                  comment.content.should.equal("Impressive picture...")
                  comment.owner_verified.should.equal("Testing_Squad")
                  done()

   #
   # /v1/highlights/[highlight_id]/vote
   #
   describe "/v1/highlights/:highlight_id/vote", () ->

      describe "POST", () ->
         before (done) -> dbSetup.load data_highlight, done
         after (done) -> dbSetup.unload data_highlight, done

         it "should 'up' vote", (done) ->
            context = @
            highlight_id = "513526fec16e8ec75f00001b"

            request
               url: "#{context.host}/v1/highlights/#{highlight_id}/vote"
               method: "POST"
               json: vote: "up"
            , (err, resp, body) ->
               return done(err) if err
               body.status.should.equal("success")
               body.up_votes.should.equal(11)
               body.down_votes.should.equal(2)
               
               Highlight.findById highlight_id, (err, highlight) ->
                  return done(err) if err
                  highlight.up_votes.should.equal(11)
                  highlight.down_votes.should.equal(2)
                  highlight.up_voted_by.length.should.equal(1)
                  highlight.down_voted_by.length.should.equal(0)
                  done()

         it "should 'down' vote and remove 'up' vote", (done) ->
            context = @
            highlight_id = "513526fec16e8ec75f00001b"

            request
               url: "#{context.host}/v1/highlights/#{highlight_id}/vote"
               method: "POST"
               json: vote: "down"
            , (err, resp, body) ->
               return done(err) if err
               body.status.should.equal("success")
               body.up_votes.should.equal(10)
               body.down_votes.should.equal(3)
               
               Highlight.findById highlight_id, (err, highlight) ->
                  return done(err) if err
                  highlight.up_votes.should.equal(10)
                  highlight.down_votes.should.equal(3)
                  highlight.up_voted_by.length.should.equal(0)
                  highlight.down_voted_by.length.should.equal(1)
                  done()

         it "should remove vote", (done) ->
            context = @
            highlight_id = "513526fec16e8ec75f00001b"

            request
               url: "#{context.host}/v1/highlights/#{highlight_id}/vote"
               method: "POST"
               json: vote: "none"
            , (err, resp, body) ->
               return done(err) if err
               body.status.should.equal("success")
               body.up_votes.should.equal(10)
               body.down_votes.should.equal(2)
               
               Highlight.findById highlight_id, (err, highlight) ->
                  return done(err) if err
                  highlight.up_votes.should.equal(10)
                  highlight.down_votes.should.equal(2)
                  highlight.up_voted_by.length.should.equal(0)
                  highlight.down_voted_by.length.should.equal(0)
                  done()

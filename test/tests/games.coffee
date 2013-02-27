require "mocha"
should = require "should"
request = require "request"
mongoose = require "mongoose"

data_games = require "../res/game-data"

dbSetup = null
TeamProfile = null
Stadium = null
User = null
Team = null

# fix game times
data_games.teams[0].schedule.pregame.game_time = new Date((new Date() / 1) + 1000 * 60 * 60 * 3)
data_games.teams[1].schedule.pregame.game_time = new Date((new Date() / 1) + 1000 * 60 * 60 * 24)

describe "Games", () ->
   before (done) ->
      dbSetup = require "../utils/dbSetup"
      Team = require "../../common/models/Team"
      TeamProfile = require "../../common/models/TeamProfile"
      User = require "../../common/models/User"
      Stadium = require "../../common/models/Stadium"
      dbSetup.unload data_games, done
      
   #
   # /v1/me/teams/[team_profile_id]/games/gameFace
   #
   describe "/v1/me/teams/[team_profile_id]/games/gameFace", () ->
      before (done) -> dbSetup.load data_games, done
      after (done) -> dbSetup.unload data_games, done

      describe "GET", () ->

         it "should work when no upcoming games in database", (done) ->
            context = @
            profile_id = "5102b17148a0c8f70c100054"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/gameFace"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.available.should.be.false
               body.home_team.should.be.ok
               done()

         it "should work when not game date", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c100007"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/gameFace"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.available.should.be.false
               body.home_team.should.be.ok
               body.away_team.should.be.ok
               done()

         it "should work when is game date and not activated game face", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c001005"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/gameFace"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.available.should.be.true
               body.meta.face_on.should.be.false
               done()

         it "should work when is game date and activated game face", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000106"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/gameFace"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.available.should.be.true
               body.meta.face_on.should.be.true
               done()

      describe "POST", () ->

         before (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c001005"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/gameFace"
               method: "POST"
               json: face_on: true
            , (err, resp, body) ->
               return done(err) if err
               done()

         it "should save gameface", (done) ->
            TeamProfile
            .findById "5102b17168a0c8f70c001005", "waiting_events", (err, profile) ->
               return done(err) if err
               for ev in profile.waiting_events
                  if ev.type == "game_face"
                     ev.event_key.should.be.ok
                     return done()

               done(new Error("Didn't add waiting event"))

         it "should update motivator's motivated count", (done) ->
            TeamProfile
            .findById "5102b17168a0c8f70c000106", "waiting_events", (err, profile) ->
               return done(err) if err
               for ev in profile.waiting_events
                  if ev.type == "game_face"
                     ev.meta.motivated_count.should.equal(1)
                     return done()

               done(new Error("Didn't update motivated count"))

   #
   # /v1/me/teams/[team_profile_id]/games/gameFace/motivate
   #
   describe "/v1/me/teams/[team_profile_id]/games/gameFace/motivate", () ->
      before (done) -> dbSetup.load data_games, done
      after (done) -> dbSetup.unload data_games, done

      describe "POST", () ->

         before (done) ->
            context = @
            request
               url: "#{context.host}/v1/me/teams/5102b17168a0c8f70c002019/games/gameFace/motivate"
               method: "POST"
               json: 
                  motivatees: ["5102b17168a0c8f70c000202"]
                  # message: "Caught you with your GameFace off!"
            , (err, resp, body) ->
               return done(err) if err
               context.body = body
               done()

         it "should send motivate message to motivatees", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000202"
            TeamProfile.findById profile_id, "waiting_events", (err, profile) ->
               return done(err) if err
               for ev in profile.waiting_events
                  if ev.type == "game_face"
                     ev.meta.motivator.team_profile_id.should.equal("5102b17168a0c8f70c002019")
                     ev.meta.motivator.name.should.equal("Mike Testing")
                     # ev.meta.motivator.message.should.equal("Caught you with your GameFace off!")
                     return done()
               
               done(new Error("Didn't update motivated"))

         it "should update attempted_motivation_count", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c002019"
            TeamProfile.findById profile_id, "waiting_events", (err, profile) ->
               return done(err) if err
               for ev in profile.waiting_events
                  if ev.type == "game_face"
                     ev.meta.attempted_motivation_count.should.equal(1)
                     return done()

               done(new Error("Didn't update motivated"))

   #
   # /v1/me/teams/[team_profile_id]/games/attendanceStreak
   #
   describe "/v1/me/teams/[team_profile_id]/games/attendanceStreak", () ->
      before (done) -> dbSetup.load data_games, done
      after (done) -> dbSetup.unload data_games, done

      describe "GET", () ->

         it "should work when no upcoming games in database", (done) ->
            context = @
            profile_id = "5102b17148a0c8f70c100054"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/attendanceStreak"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.available.should.be.false
               body.home_team.should.be.ok
               done()

         it "should work when not game day", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c100007"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/attendanceStreak"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.available.should.be.false
               body.home_team.should.be.ok
               body.away_team.should.be.ok
               done()

         it "should work when is game date and not activated attendance streak", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c001005"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/attendanceStreak"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.available.should.be.true
               body.meta.checked_in.should.be.false
               done()

         it "should work when is game date and activated attendance streak", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000106"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/attendanceStreak"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.available.should.be.true
               body.meta.checked_in.should.be.true
               done()

      describe "POST", () ->

         it "should save attendanceStreak", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c001005"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/attendanceStreak"
               method: "POST"
               json: 
                  lat: 40
                  lng: 40
            , (err, resp, body) ->
               return done(err) if err
               
               TeamProfile
               .findById profile_id, "waiting_events", (err, profile) ->
                  for ev in profile.waiting_events
                     if ev.type == "attendance_streak"
                        ev.event_key.should.be.ok
                        return done()

                  done(new Error("Didn't add waiting event"))

   #
   # /v1/me/teams/[team_profile_id]/games/guessTheScore
   #
   describe "/v1/me/teams/[team_profile_id]/games/guessTheScore", () ->
      before (done) -> dbSetup.load data_games, done
      after (done) -> dbSetup.unload data_games, done

      describe "GET", () ->

         it "should work when no upcoming games in database", (done) ->
            context = @
            profile_id = "5102b17148a0c8f70c100054"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/guessTheScore"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.available.should.be.false
               body.home_team.should.be.ok
               done()

         it "should work when not game date", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c100007"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/guessTheScore"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.available.should.be.false
               body.home_team.should.be.ok
               body.away_team.should.be.ok
               done()

         it "should work when is game date and not activated guess the score", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c001005"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/guessTheScore"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.available.should.be.true
               body.meta.picked.should.be.false
               done()

         it "should work when is game date and activated guess the score", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c000106"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/guessTheScore"
            , (err, resp, body) ->
               return done(err) if err
               body = JSON.parse(body)
               body.available.should.be.true
               body.meta.picked.should.be.true
               done()

      describe "POST", () ->

         it "should save guessTheScore", (done) ->
            context = @
            profile_id = "5102b17168a0c8f70c001005"
            request
               url: "#{context.host}/v1/me/teams/#{profile_id}/games/guessTheScore"
               method: "POST"
               json: 
                  away_score: 45
                  home_score: 52
            , (err, resp, body) ->
               return done(err) if err
               
               TeamProfile
               .findById profile_id, "waiting_events", (err, profile) ->
                  for ev in profile.waiting_events
                     if ev.type == "guess_the_score"
                        ev.event_key.should.be.ok
                        return done()

                  done(new Error("Didn't add waiting event"))
                  
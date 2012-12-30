require "mocha"
should = require "should"
http = require "http"
path = require "path"
checkForErrors = require "./checkForErrors"
viewRender = require "../middleware/viewRender"

process.env.NODE_ENV = "production"
app = require "../controllers/host"

describe "Fannect Mobile Web", () ->
   # host = null

   before (done) ->
      context = @
      server = http.createServer(app).listen 0, () ->
         context.host = "http://localhost:#{this.address().port}" 
         done()

   describe "page errors", () ->
      views = viewRender.findViews path.resolve(__dirname, "../views")
      for page, path of views
         it "should not exist for: #{page}", (done) ->
            checkForErrors page, "#{@host}#{page}", done
   

   # checkForErrors "profile.html"
   # checkForErrors "games.html"
   # checkForErrors "games-attendanceStreak.html"
   # checkForErrors "games-gameFace.html"
   # checkForErrors "games-guessTheScore.html"
   # checkForErrors "preferences.html"
   # checkForErrors "preferences-aboutFannect.html"
   # checkForErrors "preferences-aboutFullTiltVentures.html"
   # checkForErrors "profile.html"
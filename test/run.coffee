require "mocha"
should = require "should"
Browser = require "zombie"
http = require "http"

# process.env.NODE_ENV = "production"
app = require "../controllers/host"

describe "check for page errors", () ->
   before (done) ->
      context = this
      server = http.createServer(app).listen 0, () ->
         context.port = this.address().port;
         context.host = "http://localhost:#{context.port}" 
         done()

   it "should not break", (done) ->
      Browser.visit "#{@host}/games.html", { debug: true, runScripts: true }, (e, browser) ->
         # console.log browser.errors
         # browser.errors.length.should.equal(0)
         # if (browser.error )
         console.log("Errors reported:", browser.errors.length);

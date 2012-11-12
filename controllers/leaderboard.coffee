express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/leaderboard", (req, res, next) ->
   res.render "leaderboard/leaderboard"

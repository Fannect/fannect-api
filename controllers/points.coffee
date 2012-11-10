express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/points", (req, res, next) ->
   res.render "points/points"

app.get "/points/guessTheScore", (req, res, next) ->
   res.render "points/guessTheScore/pick"

app.get "/points/attendanceStreak", (req, res, next) ->
   res.render "points/attendanceStreak"

app.get "/points/gameFace", (req, res, next) ->
   res.render "points/gameFace"

app.get "/points/suggestGame", (req, res, next) ->
   res.render "points/suggestGame"


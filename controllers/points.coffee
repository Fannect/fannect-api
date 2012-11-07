express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/points", (req, res, next) ->
   res.render "points/points"

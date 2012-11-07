express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/", (req, res, next) ->
   res.render "points"
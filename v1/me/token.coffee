express = require "express"
mongoose = require "mongoose"
User = require "../../models/User"

app = module.exports = express()

# Retrieve access_token and refresh_token (login)
app.post "/v1/me/token", (req, res, next) ->
   email = req.body.email
   password = req.body.password


   res.json
      access_token: "123"
      refresh_token: "1234"

# Refresh access_token with refresh_token
app.put "/v1/me/token", (req, res, next) ->
   refresh_token = req.body.refresh_token
   
   res.json
      access_token: "123"
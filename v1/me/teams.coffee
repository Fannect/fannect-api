express = require "express"

app = module.exports = express()

# Get team profiles
app.get "/v1/me/teams", (req, res, next) ->
   res.json
      teams: []

# Add team profile
app.post "/v1/me/teams", (req, res, next) ->
   team_id = req.body.team_id

   res.json
      access_token: 

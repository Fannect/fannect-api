express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/v1/me/games/gameFace", (req, res, next) ->
   gameInfo = 
      available: true
      face_value: "off"
      home_team:
         name: "Kansas Jayhawks"
         record: "(31-3, 14-2)"
      away_team:
         name: "Missouri Tigers"
         record: "(31-3, 14-2)"
   res.json gameInfo
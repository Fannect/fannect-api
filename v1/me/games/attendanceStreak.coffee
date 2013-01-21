express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/v1/me/games/attendanceStreak", (req, res, next) ->
   gameInfo = 
      home_team:
         name: "Kansas Jayhawks"
         record: "(31-3, 14-2)"
      away_team:
         name: "Missouri Tigers"
         record: "(31-3, 14-2)"
      stadium:
         name: "Allen Fieldhouse"
         location: "Lawrence, Kansas"
         lat: 38.953834
         lng: -95.252829
      checked_in: false
      no_game: false
      next_game: "January 27, 2013"

   res.json gameInfo
express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/v1/me/games/guessTheScore", (req, res, next) ->
   gameInfo =
      available: true
      picked: true
      home_team:
         picked_score: 34
         name: "Kansas Jayhawks"
         record: "(31-3, 14-2)"
      away_team:
         picked_score: 43
         name: "Missouri Tigers"
         record: "(31-3, 14-2)"
      game_preview: "Here is where the game preview would go."

   res.json gameInfo
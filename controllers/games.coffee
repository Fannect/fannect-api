express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/me/games/guessTheScore", (req, res, next) ->
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

# app.post "/points/guessTheScore", (req, res, next) ->
#    res.redirect "/points/guessTheScore/guessed"

# app.get "/points/guessTheScore/guessed", (req, res, next) ->
#    gameInfo =
#       home:
#          guess: 137
#          name: "Kansas Jayhawks"
#          record: "(31-3, 14-2)"
#       away:
#          guess: 68
#          name: "Missouri Tigers"
#          record: "(31-3, 14-2)"

#    res.render "points/guessTheScore/picked", gameInfo

app.get "/me/games/attendanceStreak", (req, res, next) ->
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

# app.post "/points/attendanceStreak"

app.get "/me/games/gameFace", (req, res, next) ->
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

# app.get "/points/suggestGame", (req, res, next) ->
#    res.render "points/suggestGame"


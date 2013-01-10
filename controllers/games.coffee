express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/api/games/guessTheScore", (req, res, next) ->
   gameInfo =
      available: true
      picked: true
      home:
         picked_score: 34
         name: "Kansas Jayhawks"
         record: "(31-3, 14-2)"
      away:
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

app.get "/api/games/attendanceStreak", (req, res, next) ->
   gameInfo = 
      home:
         name: "Kansas Jayhawks"
         record: "(31-3, 14-2)"
      away:
         name: "Missouri Tigers"
         record: "(31-3, 14-2)"
      stadium:
         name: "Allen Fieldhouse"
         location: "Lawrence, Kansas"
      checked_in: false
      no_game: false
      next_game: "January 27, 2013"

   res.json gameInfo

# app.post "/points/attendanceStreak"

app.get "/api/games/gameFace", (req, res, next) ->
   gameInfo = 
      available: false
      face_value: "off"
      home:
         name: "Kansas Jayhawks"
         record: "(31-3, 14-2)"
      away:
         name: "Missouri Tigers"
         record: "(31-3, 14-2)"
   res.json gameInfo

# app.get "/points/suggestGame", (req, res, next) ->
#    res.render "points/suggestGame"


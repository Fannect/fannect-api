express = require "express"

app = module.exports = express()

app.get "/v1/me/games", (req, res, next) ->
   res.json ["guessTheScore", "attendanceStreak", "gameFace"]

app.use require "./games/attendanceStreak"
app.use require "./games/gameFace"
app.use require "./games/guessTheScore"
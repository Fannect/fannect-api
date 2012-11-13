express = require "express"
rest = require "request"

app = module.exports = express()

app.get "/points", (req, res, next) ->
   res.render "points/points"

app.get "/points/guessTheScore", (req, res, next) ->
   gameInfo =
      home:
         name: "Kansas Jayhawks"
         record: "(31-3, 14-2)"
      away:
         name: "Missouri Tigers"
         record: "(31-3, 14-2)"

   res.render "points/guessTheScore/pick", gameInfo

app.post "/points/guessTheScore", (req, res, next) ->
   res.redirect "/points/guessTheScore/guessed"

app.get "/points/guessTheScore/guessed", (req, res, next) ->
   gameInfo =
      home:
         guess: 137
         name: "Kansas Jayhawks"
         record: "(31-3, 14-2)"
      away:
         guess: 68
         name: "Missouri Tigers"
         record: "(31-3, 14-2)"

   res.render "points/guessTheScore/picked", gameInfo

app.get "/points/attendanceStreak", (req, res, next) ->
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

   res.render "points/attendanceStreak", gameInfo

app.post "/points/attendanceStreak"

app.get "/points/gameFace", (req, res, next) ->
   gameInfo = 
      home:
         name: "Kansas Jayhawks"
         record: "(31-3, 14-2)"
      away:
         name: "Missouri Tigers"
         record: "(31-3, 14-2)"
   res.render "points/gameFace/gameDay", gameInfo

app.get "/points/gameFace/noGame", (req, res, next) ->
   gameInfo = 
      home:
         name: "Kansas Jayhawks"
         record: "(31-3, 14-2)"
      away:
         name: "Missouri Tigers"
         record: "(31-3, 14-2)"
   res.render "points/gameFace/noGame", gameInfo

app.get "/points/suggestGame", (req, res, next) ->
   res.render "points/suggestGame"


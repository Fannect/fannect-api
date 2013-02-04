express = require "express"

app = module.exports = express()

app.use require "../v1/me"
app.use require "../v1/leaderboard"
app.use require "../v1/users"
app.use require "../v1/teamProfiles"
app.use require "../v1/images"
app.use require "../v1/teams"
app.use require "../v1/sports"
app.use require "../v1/stadiums"
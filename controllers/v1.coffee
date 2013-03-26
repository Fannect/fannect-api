express = require "express"

app = module.exports = express()

app.use require "../v1/me"
app.use require "../v1/leaderboard"
app.use require "../v1/users"
app.use require "../v1/teamProfiles"
app.use require "../v1/groups"
app.use require "../v1/huddles"
app.use require "../v1/highlights"
app.use require "../v1/images"
app.use require "../v1/teams"
app.use require "../v1/share"
app.use require "../v1/sports"
app.use require "../v1/stadiums"
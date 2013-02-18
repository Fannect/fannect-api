express = require "express"
mongoose = require "mongoose"
User = require "../common/models/User"
auth = require "../common/middleware/authenticate"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"
NotAuthorizedError = require "../common/errors/NotAuthorizedError"
RestError = require "../common/errors/RestError"
sendgrid = new (require("sendgrid-web"))({ 
   user: process.env.SENDGRID_USER or "fannect", 
   key: process.env.SENDGRID_PASSWORD or "1Billion!" 
})
fs = require "fs"
path = require "path"
shareHtml = null

app = module.exports = express()

# Get this user
app.get "/v1/share/email", auth.rookieStatus, (req, res, next) ->
   send = () ->
      sendgrid.send
         to: req.user.email
         fromname: "Joe Fannect"
         from: "team@fannect.me"
         subject: "Download Fannect"
         html: shareHtml.replace("REPLACE_THIS_WITH_NAME", "#{req.user.first_name} #{req.user.last_name}")
      , (err) ->  
         return next(new RestError(err)) if err
         res.json status: "success"

   if not shareHtml
      fs.readFile path.resolve(__dirname, "../res/shareEmail.html"), "utf8", (err, data) ->
         shareHtml = data
         send()
   else
      send()

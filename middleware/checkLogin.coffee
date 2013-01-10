sf = require "node-salesforce"

module.exports = (req, res, next) ->
   # if not req.session?.auth
   #    return res.json 401,
   #       status: "fail"
   #       error_message: "Unauthorized access."
   # else
   #    next()

   req.conn = conn = new sf.Connection()
   conn.login "frankenstein@fannect.com", "testing", (err, userInfo) ->
      req.session.user_id = userInfo.id
      next()
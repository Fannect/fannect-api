auth = require "../../common/middleware/authenticate"

passthrough = (req, res, next) ->
   req.user = {
      "_id": "5102b17168a0c8f70c000002",
      "email": "testing1@fannect.me",
      "password": "hi",
      "first_name": "Mike",
      "last_name": "Testing",
      "refresh_token": "testingtoken"
   }
   next()

auth.rookie = passthrough
auth.sub = passthrough
auth.starter = passthrough
auth.allstar = passthrough
auth.mvp = passthrough
auth.hof = passthrough
express = require "express"
path = require "path"
redis = require "redis-url"
mongoose = require "mongoose"
mongooseTypes = require "mongoose-types"
redis = (require "../utils/redis")(process.env.REDIS_URL or "redis://redistogo:f74caf74a1f7df625aa879bf817be6d1@perch.redistogo.com:9203")

app = module.exports = express()

# Settings
app.configure "development", () ->
   app.use express.logger "dev"
   app.use express.errorHandler { dumpExceptions: true, showStack: true }

app.configure "production", () ->
   app.use express.errorHandler()

# Middleware
app.use express.query()
app.use express.bodyParser()
app.use express.cookieParser process.env.COOKIE_SECRET or "super duper secret"
app.use express.static path.join __dirname, "../public"

# Set up mongoose
mongoose.connect process.env.MONGO_URL or "mongodb://admin:testing@linus.mongohq.com:10064/fannect"
mongooseTypes.loadTypes mongoose




# db.on "error", console.error.bind(console, "connection error:")
# db.once "open", () -> "Mongo connected."

#Session
# redis_client = redis.connect(process.env.REDISTOGO_URL or "redis://heroku.bad942ab42933a1bd148:d83a3ae81b3c7e67314831b9c167459e@clingfish.redistogo.com:9480/")
# app.use express.session
#    cookie: maxAge: 60000 * 2880
#    store: new RedisStore(client: redis_client)

# Login controller
# app.use require "./login"



# Check login
# app.use require "../middleware/checkLogin"

# Controllers
app.use require "./v1"

# Error handling
app.use require "../middleware/handleErrors"

app.all "*", (req, res) ->
   res.json 404,
      status: "fail"
      message: "Resource not found."


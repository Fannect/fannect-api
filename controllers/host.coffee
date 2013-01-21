express = require "express"
path = require "path"
RedisStore = require("connect-redis")(express)
redis = require("redis-url")

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

#Session
# redis_client = redis.connect(process.env.REDISTOGO_URL or "redis://heroku.bad942ab42933a1bd148:d83a3ae81b3c7e67314831b9c167459e@clingfish.redistogo.com:9480/")
# app.use express.session
#    cookie: maxAge: 60000 * 2880
#    store: new RedisStore(client: redis_client)

# Login controller
# app.use require "./login"

# Check login
app.use require "../middleware/checkLogin"

# Controllers
app.use require "./v1"

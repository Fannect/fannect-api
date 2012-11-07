express = require "express"
MongoStore = require("connect-mongo")(express)
path = require "path"
RedisStore = require("connect-redis")(express)
redis = require("redis-url")

app = module.exports = express()

# Settings
app.set "view engine", "jade"
app.set "view options", layout: false
app.set "views", path.join __dirname, "../views"

app.configure "development", () ->
   app.use express.logger "dev"
   app.use express.errorHandler { dumpExceptions: true, showStack: true }

app.configure "production", () ->
   app.use express.errorHandler()

# Middleware
app.use express.query()
app.use express.bodyParser()
app.use express.cookieParser process.env.COOKIE_SECRET or "super duper secret"
app.use require("connect-assets")()
app.use express.static path.join __dirname, "../public"
# app.use require("../middleware/utils").root

#Session
# redis_client = redis.connect(process.env.REDISTOGO_URL or "redisurlhere")
# redis_client.on "ready", () -> console.log "Redis connected."
# sessionStore =  new RedisStore
#    client: redis_client
# app.use express.session
#    cookie:
#       maxAge: 60000 * 2880
#    store: sessionStore

# Controllers
app.use require "./points"
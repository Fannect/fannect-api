path = require "path"
fs = require "fs"

cachedPaths = {}
hasCached = false

module.exports = (req, res, next) ->
   unless hasCached
      cacheViews path.resolve(__dirname, "../views")
      hasCached = true

   if cachedPaths[req.url]
      res.render cachedPaths[req.url]
   else
      next() 
   
cacheViews = (dir, done) ->
   list = fs.readdirSync dir

   for file in list
      filePath = path.resolve dir, file
      stat = fs.statSync filePath
      
      if stat and stat.isDirectory()
         cacheViews filePath
      else
         cachedPaths["/" + file.replace("jade", "html")] = filePath









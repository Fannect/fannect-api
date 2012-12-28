path = require "path"
fs = require "fs"

cachedPaths = {}
hasCached = false
baseDir = path.resolve(__dirname, "../views")

module.exports = (req, res, next) ->
   unless hasCached
      cacheViews baseDir
      hasCached = true

   url = req.url.toLowerCase()

   if cachedPaths[url]
      res.render cachedPaths[url]
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
         filename = filePath.replace(baseDir, "").replace("jade", "html").replace(/^[\\\/]/g, "").replace(/[\\\/]/g, "-").toLowerCase()
         cachedPaths["/" + filename] = filePath









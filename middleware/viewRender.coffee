path = require "path"
fs = require "fs"

cachedPaths = {}
hasCached = false

module.exports = (req, res, next) ->
   unless hasCached
      cachedPaths = module.exports.findViews path.resolve(__dirname, "../views")
      hasCached = true

   url = req.url.toLowerCase()

   if cachedPaths[url]
      res.render cachedPaths[url]
   else
      next() 
   
module.exports.findViews = (baseDir) ->
   views = {}

   findViewFromDir = (dir) ->
      list = fs.readdirSync dir

      for file in list
         filePath = path.resolve dir, file
         stat = fs.statSync filePath
         
         if stat and stat.isDirectory()
            findViewFromDir filePath
         else
            filename = filePath.replace(baseDir, "").replace("jade", "html").replace(/^[\\\/]/g, "").replace(/[\\\/]/g, "-").toLowerCase()
            views["/" + filename] = filePath

   findViewFromDir baseDir
   return views









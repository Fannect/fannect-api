path = require "path"
fs = require "fs"
jade = require "jade"
async = require "async"

hasCachedPaths = false
cachedViewPaths = {}
cachedHtml = {}

baseDir = path.resolve(__dirname, "../views")

viewRender = module.exports = (req, res, next) ->
   unless hasCachedPaths
      cachedViewPaths = viewRender.findViews baseDir

   url = req._parsedUrl.pathname.toLowerCase()

   if cachedViewPaths[url]
      if cachedHtml[url] and process.env.NODE_ENV == "production"
         res.send cachedHtml[url]
      else
         compileJade cachedViewPaths[url], (err, html) ->
            cachedHtml[url] = html
            res.send html
   else
      next()
   
viewRender.findViews = (base) ->
   views = {}

   findViewFromDir = (dir) ->
      list = fs.readdirSync dir

      for file in list
         filePath = path.resolve dir, file
         stat = fs.statSync filePath
         
         if stat and stat.isDirectory()
            findViewFromDir filePath
         else
            filename = filePath.replace(base, "").replace("jade", "html").replace(/^[\\\/]/g, "").replace(/[\\\/]/g, "-").toLowerCase()
            views["/" + filename] = filePath

   findViewFromDir base
   return views

compileJade = (filePath, next) ->
   fs.readFile filePath, (err, contents) ->
      if err then next err 
      html = jade.compile(contents,
         debug: false
         filename: filePath
      )({settings: {views:baseDir}, filename: filePath})

      next null, html
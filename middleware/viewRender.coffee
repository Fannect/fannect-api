path = require "path"
fs = require "fs"
jade = require "jade"
async = require "async"

cachedHtml = {}
hasCached = false

viewRender = module.exports = (req, res, next) ->
   unless hasCached
      cacheHtml path.resolve(__dirname, "../views"), (err, result) ->
         throw err if err
         cachedHtml = result 
         hasCached = true
         handle req, res, next
   else 
      handle req, res, next
   
viewRender.findViews = (baseDir) ->
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

handle = (req, res, next) ->
   url = req.url.toLowerCase()

   if cachedHtml[url]
      res.send cachedHtml[url]
   else
      next() 

cacheHtml = (baseDir, done) ->
   views = viewRender.findViews baseDir

   makeFn = (filePath) ->
      return (next) ->
         compileJade(filePath, next)

   compileJade = (filePath, next) ->
      fs.readFile filePath, (err, contents) ->
         if err then next err 
         html = jade.compile(contents,
            debug: false
            filename: filePath
         )({settings: {views:baseDir}, filename: filePath})

         next null, html

   parallel = {}
   for name, filePath of views
         parallel[name] = makeFn filePath

   async.parallel parallel, (err, compiled) ->
      done err, compiled





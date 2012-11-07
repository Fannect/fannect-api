path = require "path"

module.exports =
   root: (req, res, next) ->
      # Add root to locals to allow for page specific body class
      res.locals.root = path.resolve __dirname, "../views"
      next() 
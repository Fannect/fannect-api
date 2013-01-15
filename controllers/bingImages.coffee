express = require "express"
request = require "request"
https = require "https"

accountKey = process.env.BING_IMAGE_KEY or "DzZgf34XWljeZxOPoUFQNOYHmL7SV+7hy4HFXQIHWH4="
authKey = new Buffer("#{accountKey}:#{accountKey}").toString("base64")
perPage = 20

app = module.exports = express()

app.get "/find/images", (req, res, next) ->
   unless req.query then return req.json status: "fail"
   page = if not req.query.page or req.query.page < 0 then 0 else req.query.page

   request 
      uri: "https://api.datamarket.azure.com/Data.ashx/Bing/Search/v1/Image?$top=#{perPage}&$skip=#{page*perPage}&$format=json&Query=%27#{escape(req.query.query)}%27"
      method: "GET"
      headers: 
         "Authorization": "Basic #{authKey}"
   , (error, resp, body) ->
      if error
         res.json 
            status: "fail"
            error_message: error
      else if resp.statusCode >= 400
         res.json 
            status: "fail"
            error_message: body
      else
         res.json parseResults JSON.parse body

parseResults = (data) ->
   results = []

   for image in data.d.results
      results.push
         url: image.MediaUrl
         width: image.Width
         height: image.Height
         thumbnail:
            url: image.Thumbnail.MediaUrl
            width: image.Thumbnail.Width
            height: image.Thumbnail.Height

   return results
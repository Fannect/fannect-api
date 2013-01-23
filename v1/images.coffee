fs = require "fs"
express = require "express"
request = require "request"
images = require "../common/utils/images"

app = module.exports = express()

# Bing settings
accountKey = process.env.BING_IMAGE_KEY or "DzZgf34XWljeZxOPoUFQNOYHmL7SV+7hy4HFXQIHWH4="
authKey = new Buffer("#{accountKey}:#{accountKey}").toString("base64")
perPage = 20

# Updates this user's profile image
app.post "/v1/images/me", (req, res, next) ->
   if req.files?.image?.path
      images.uploadToCloud req.files.image.path,
         [{ width: 280, height: 280, crop: "fill", gravity: "faces" }]
      , (error, result) ->
         if error
            res.json error.http_code or 400,
               status: "fail"
               message: error.message
         else
            res.json 
               image_url: result.url

# Updates this user'r profile image to specified url
app.put "/v1/images/me", (req, res, next) ->
   image_url = req.body.image_url
   res.json status: "success"

# Updates the team profile image
app.post "/v1/images/me/:team_profile_id", (req, res, next) ->
   image_path = req.files?.image.path or req.body?.image_url
   if image_path
      images.uploadToCloud image_path,
         [{ width: 376, height: 376, crop: "fill", gravity: "faces" }]
      , (error, result) ->
         if error
            res.json error.http_code or 400,
               status: "fail"
               message: error.message
         else
            res.json 
               image_url: result.url
            
app.put "/v1/images/me/:team_profile_id", (req, res, next) ->
   image_url = req.body.image_url
   res.json status: "success"

# Search Bing images
app.get "/v1/images/bing", (req, res, next) ->
   unless req.query then return req.json status: "fail"
   q = req.query.q
   limit = req.query.limit
   skip = req.query.skip

   request 
      uri: "https://api.datamarket.azure.com/Data.ashx/Bing/Search/v1/Image?$top=#{limit}&$skip=#{skip}&$format=json&Query=%27#{escape(q)}%27"
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
         res.json parseBingResults JSON.parse body

parseBingResults = (data) ->
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
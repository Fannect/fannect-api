fs = require "fs"
express = require "express"
request = require "request"
cloudinary = require "cloudinary"

cloudinary.config "cloud_name", "fannect-dev"
cloudinary.config "api_key", "498234921417922"
cloudinary.config "api_secret", "Q4qI_uIoi5D4fwkGOIDm84xZMQc"

app = module.exports = express()

# Bing settings
accountKey = process.env.BING_IMAGE_KEY or "DzZgf34XWljeZxOPoUFQNOYHmL7SV+7hy4HFXQIHWH4="
authKey = new Buffer("#{accountKey}:#{accountKey}").toString("base64")
perPage = 20

# Updates this user's profile image
app.put "/v1/images/me", (req, res, next) ->
   res.json
      image_url: ""

# Updates the team profile image
app.put "/v1/images/me/:team_profile_id", (req, res, next) ->
   console.log image_url = req.body.image_url


   if image_url
      cloudinary.uploader.upload image_url, (result) ->
         res.json image_url: result.url
         # TODO: POST URL TO MONGO
         console.log(result) 
      , [{ width: 190, height: 190, crop: "fill", gravity: "faces" }]
   else
      res.json
         image_url: ""
            
# cloudinary.url("sample_remote.jpg")



   # file_reader = fs.createReadStream('my_picture.jpg', {encoding: 'binary'})
   #    .on('data', stream.write)
   #    .on('end', stream.end)
   # stream = cloudinary.uploader.upload_stream(function(result) { console.log(result); });


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
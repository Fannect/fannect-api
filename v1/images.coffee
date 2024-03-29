fs = require "fs"
express = require "express"
request = require "request"
images = require "../common/utils/images"
InvalidArgumentError = require "../common/errors/InvalidArgumentError"
MongoError = require "../common/errors/MongoError"
RestError = require "../common/errors/RestError"
auth = require "../common/middleware/authenticate"
TeamProfile = require "../common/models/TeamProfile"
User = require "../common/models/User"
Huddle = require "../common/models/Huddle"
async = require "async"
twitter = require "../common/utils/twitterReq"
ProfileImageJob = require "../common/jobs/ProfileImageJob"

app = module.exports = express()

# Bing settings
accountKey = process.env.BING_IMAGE_KEY or "DzZgf34XWljeZxOPoUFQNOYHmL7SV+7hy4HFXQIHWH4="
authKey = new Buffer("#{accountKey}:#{accountKey}").toString("base64")
perPage = 30

# Updates this user's profile image
app.post "/v1/images/me", auth.rookieStatus, (req, res, next) ->
   pull_twitter = req.body.pull_twitter or false

   if pull_twitter
      return next(new InvalidArgumentError("No twitter account connected to this user")) unless req.user.twitter
      twitter.pullProfile req.user.twitter, (err, url) ->
         if err
            next(new RestError("Twitter account no longer authorized.")) 

            req.user.twitter = null
            async.parallel 
               mongo: (done) -> User.update {_id: req.user._id}, {twitter:null}, done
               redis: (done) -> auth.updateUser req.query.access_token, req.user, done
            , (err) -> console.error "Twitter update ERR:", err
         else
            images.uploadToCloud url,
               [{ width: 280, height: 280, crop: "fill", gravity: "faces", quality: 100 }]
            , (err, result) ->
               return next(new InvalidArgumentError("Unable to save image")) if err
               
               updateUserProfileImage req.user._id, result.url, (err, data) ->
                  return next(new MongoError(err)) if err
                  res.json profile_image_url: result.url
   else
      image_path = req.files?.image.path or req.body?.image_url
      next(new InvalidArgumentError("Required: image or image_url")) unless image_path

      images.uploadToCloud image_path,
         [{ width: 280, height: 280, crop: "fill", gravity: "faces", quality: 100 }]
      , (err, result) ->
         return next(new InvalidArgumentError("Unable to save image")) if err
         
         updateUserProfileImage req.user._id, result.url, (err, data) ->
            return next(new MongoError(err)) if err
            res.json profile_image_url: result.url
      
updateProfileImage = (req, res, next) ->
   image_url = req.body.image_url
   return next(new InvalidArgumentError("Required: image_url")) unless image_url
   updateUserProfileImage req.user._id, image_url, (err, data) ->
      return next(new MongoError(err)) if err
      res.json status: "success"

app.put "/v1/images/me", auth.rookieStatus, updateProfileImage
app.post "/v1/images/me/update", auth.rookieStatus, updateProfileImage

# Updates the team profile image
app.post "/v1/images/me/:team_profile_id", auth.rookieStatus, (req, res, next) ->
   team_profile_id = req.params.team_profile_id

   image_path = req.files?.image?.path or req.body?.image_url
   next(new InvalidArgumentError("Required: image or image_url")) unless image_path

   images.uploadToCloud image_path,
      [{ width: 376, height: 376, crop: "fill", gravity: "faces", quality: 100 }]
   , (err, result) ->
      return next(new InvalidArgumentError("Unable to save image")) if err
      
      TeamProfile.update { _id: team_profile_id, is_active: true }
      , team_image_url: result.url
      , (err, data) ->
         return next(new MongoError(err)) if err
         return next(new ResourceNotFoundError("Not found: TeamProfile")) unless data == 1
         res.json team_image_url: result.url

updateTeamImage = (req, res, next) ->
   image_url = req.body.image_url
   return next(new InvalidArgumentError("Required: image_url")) unless image_url

   TeamProfile.update { _id: req.params.team_profile_id }
   , team_image_url: image_url
   , (err, data) ->
      return next(new MongoError(err)) if err
      return next(new ResourceNotFoundError("Not found: TeamProfile")) unless data == 1
      res.json status: "success"
      
app.put "/v1/images/me/:team_profile_id", auth.rookieStatus, updateTeamImage
app.post "/v1/images/me/:team_profile_id/update", auth.rookieStatus, updateTeamImage

# Get Cloudinary signed token
app.post "/v1/images/signature", auth.rookieStatus, (req, res, next) ->
   res.json
      cloud_name: images.getCloudName()
      params: images.getParams(req.body)

app.get "/v1/images/instagram", auth.rookieStatus, (req, res, next) ->
   return next(new InvalidArgumentError("No Instagram account attached to user.")) unless req.user.instagram
   limit = req.query.limit or 20
   limit = parseInt(limit)
   limit = if limit > 40 then 40 else limit
   max_id = req.query.max_id

   qs = 
      count: limit
      access_token: req.user.instagram.access_token
   qs.max_id = max_id if max_id

   request 
      uri: "https://api.instagram.com/v1/users/#{req.user.instagram.id}/media/recent"
      qs: qs
      method: "GET"
   , (err, resp, body) ->
      return next(new RestError(err)) if err
      
      if resp.statusCode >= 400
         unlinkInstagram(req.query.access_token, req.user)
         return next(new InvalidArgumentError("Instagram OAuth has expired.")) 
      
      body = JSON.parse(body)
      results = []
      for image in body.data
         results.push
            url: image.images.standard_resolution.url
            width: image.images.standard_resolution.width
            height: image.images.standard_resolution.height
            thumbnail: 
               url: image.images.low_resolution.url
               width: image.images.low_resolution.width
               height: image.images.low_resolution.height

      res.json 
         meta: 
            next_max_id: body?.data?[body.data.length-1]?.id
         images: results

# Search Bing images
app.get "/v1/images/bing", auth.rookieStatus, (req, res, next) ->
   return next(new InvalidArgumentError("Required: q")) unless req.query?.q
   q = req.query.q
   skip = req.query.skip
   limit = req.query.limit
   limit = if limit > 40 then 40 else limit

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

updateUserProfileImage = (user_id, url, cb) ->
   async.parallel
      profile: (done) ->
         TeamProfile.update { user_id: user_id }
         , { profile_image_url: url }
         , { multi: true }
         , done
      user: (done) ->
         User.update { _id: user_id }
         , { profile_image_url: url }
         , done
      huddle: (done) ->
         job = new ProfileImageJob({ user_id: user_id, new_image_url: url })
         job.queue(done)
   , cb

unlinkInstagram = (access_token, user) ->
   delete user.instagram
   async.parallel 
      mongo: (done) -> User.update {_id: user._id}, { instagram:null }, done
      redis: (done) -> auth.updateUser access_token, user, done
   , (err) ->

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
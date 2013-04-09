# Fannect API

This is the source for the Fannect core API.

## Table of Contents
  * [REST Schema](#rest-schema)
  * [Role Levels](#roles-levels)
  * [Steps to Verify User](#steps-to-verify-user)

## REST Schema
The full REST Schema can be found in the [wiki](https://github.com/Fannect/fannect-api/wiki).

## Environmental Variables
* MONGO_URL - primary database url
* REDIS_URL - primary redis url, used for session
* REDIS_QUEUE_URL - queue redis url, used for worker
* CLOUDINARY_NAME
* CLOUDINARY_KEY
* CLOUDINARY_SECRET
* BING_IMAGE_KEY
* SENDGRID_USERNAME
* SENDGRID_PASSWORD
* PARSE_APP_ID
* PARSE_API_KEY

## Roles Levels

### User
* rookie - all normal Fannect users
* sub
* starter
* allstar
* mvp
* hof - Fannect team, required to upload teams doc

### App
* manager
* owner - unused at this point

## Steps to Verify User

### Get access token
First you will need to get an access_token for an account that has `hof` status (see above).

Send a `POST` request to `https://fannect-login.herokuapp.com/v1/token` with the following forms:
* `email` - obviously your email
* `password` - your password

__Copy__ the `access_token` in the response into your clipboard.

### Make request to verified endpoint

Send a `PUT` request to `http://api.fannect.me/v1/users/[user_id]/verified` with the following:
* replace `[user_id]` with the user's mongo `_id`
* `verified` - the users new verification status, to clear verification status do NOT include, determine the correct value using the run below

#### Determining Verified Status 
* prefix any players with `player_`
* prefix any coach with `coach_`
* prefix any sports authority with `authority_`
* suffix with the related sport

Examples
* `player_basketball`
* `coach_basketball`
* `authority_all`
* `authority_basketball`

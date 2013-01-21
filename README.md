# Fannect API
[![Build Status](https://secure.travis-ci.org/Fannect/fannect-mobileweb.png?branch=master)](https://travis-ci.org/Fannect/fannect-mobileweb)

This is the source for the Fannect core API.

# REST Schema
This is based on [this video](http://blog.apigee.com/detail/restful_api_design) by apigee

### `/v1/me`
* GET - get profile information for this user
* POST - creating original account for this user

### `/v1/me/token`
* POST - Creates new `access_token` and `refresh_token` with credentials 
* PUT - Creates new `access_token` with `refresh_token`

### `/v1/me/teams`
* GET - get all team profiles
* POST - add a new team profile to the user

### `/v1/me/teams/[profile_team_id]`
* GET - gets the team profile
* PUT - update the team profile

### `/v1/me/invites`
* GET - lists all friend invite
* POST - creates a friend invite
* DELETE - deletes a friend invite

### `/v1/me/games`
* GET - lists all available games for this user

### `/v1/me/games/[game]`
* GET - get current game state for this user
* PUT - update current game state for this user

### `/v1/leaderboard/[team_id]`
* GET - gets the overall leaderboard for a team
   * `friends_only` - [false] restrict to friends only

### `/v1/users`
* GET - gets users with filter
   * `q` - query to filter users
   * `friends_only` - [false] restrict to friends only

### `/v1/leagues`
* GET - lists available leagues

### `/v1/leagues/[league]/teams`
* GET - ?

### `/v1/images/me`
* PUT - Updates this user's profile image

### `/v1/images/me/[team_profile_id]`
* PUT - Updates the team image for this profile

### `/v1/images/bing`
* GET - Search Bing for images
   * q - query to search by
   * limit - number of images to return
   * skip - images to skip


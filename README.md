# Fannect API
[![Build Status](https://secure.travis-ci.org/Fannect/fannect-mobileweb.png?branch=master)](https://travis-ci.org/Fannect/fannect-mobileweb)

This is the source for the Fannect core API.

# REST Schema
This is based on [this video](http://blog.apigee.com/detail/restful_api_design) by apigee

### `/v1/me`
* GET - get profile information for this user
* PUT - update profile information
  * `first_name`
  * `last_name`

### `/v1/me/teams`
* GET - get all team profiles
* POST - add a new team profile to the user
  * `team_id` - team_id to create profile for

### `/v1/me/teams/[team_profile_id]`
* GET - gets the team profile
* PUT - update the team profile

### `/v1/me/invites`
* GET - lists all friend invite
* POST - creates a friend invite
  * `user_id` - accepts the user's invite
* DELETE - deletes a friend invite

### `/v1/me/games`
* GET - lists all available games for this user

### `/v1/me/games/[game]`
* GET - get current game state for this user
* PUT - update current game state for this user

### `/v1/leaderboard/users/[team_id]`
* GET - gets the overall leaderboard for a team
   * `friends_only` - [false] restrict to friends only

### `/v1/leaderboard/teams/[team_id]/conference`
* GET - gets leaderbaord based on conference

### `/v1/leaderboard/teams/[team_id]/league`
* GET - gets leaderboard based on league
 
### `/v1/leaderboard/teams/[team_id]/breakdown`
* GET - gets points breakdown for this team 

### `/v1/leaderboard/teams/[team_id]/custom`
* GET - gets comparison between this team and another
  * `q` - team to compare against

### `/v1/users`
* GET - gets users with filter
   * `q` - query to filter users
   * `friends_only` - [false] restrict to friends only

### `/v1/sports`
* GET - lists available sports

### `/v1/sports/[sport_key]/leagues`
* GET - lists available leagues for this sport

### `/v1/sports/[sport_key]/leagues/[league_key]/teams`
* GET - lists available teams for this league

### `/v1/

### `/v1/images/me`
* PUT - Updates this user's profile image

### `/v1/images/me/[team_profile_id]`
* PUT - Updates the team image for this profile

### `/v1/images/bing`
* GET - Search Bing for images
   * q - query to search by
   * limit - number of images to return
   * skip - images to skip


## Roles Levels
* rookie - all normal Fannect users
* sub
* starter
* allstar
* mvp
* hof - Fannect team, required to upload teams doc

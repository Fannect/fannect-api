# Fannect API
[![Build Status](https://secure.travis-ci.org/Fannect/fannect-mobileweb.png?branch=master)](https://travis-ci.org/Fannect/fannect-mobileweb)

This is the source for the Fannect core API.

# REST Schema
This is based on [this video](http://blog.apigee.com/detail/restful_api_design) by apigee

### `/v1/me`
* GET - get profile information for this user

```javascript
{ _id: '5102b17168a0c8f70c000002',
  email: 'testing1@fannect.me',
  password: 'hi',
  first_name: 'Mike',
  last_name: 'Testing',
  refresh_token: 'testingtoken',
  friends: [ '5102b17168a0c8f70c000004' ] }
```

* PUT - update profile information
  * `first_name`
  * `last_name`

```javascript
{ status: 'success' }
```

### `/v1/me/teams`
* GET - get all team profiles

```javascript
[ { _id: '5102b17168a0c8f70c000005',
    team_id: '5102b17168a0c8f70c000008',
    team_key: 'l.ncaa.org.mfoot-t.522',
    team_name: 'Kansas St. Wildcats',
    trash_talk: [],
    points: { dedication: 5, passion: 3, knowledge: 2, overall: 10 } } ]
```

* POST - add a new team profile to the user
  * `team_id` - team_id to create profile for

```javascript
{ __v: 0,
  _id: '510338a985e7e53d1f000003',
  user_id: '5102b17168a0c8f70c000002',
  name: 'Mike Testing',
  team_id: '5102b17168a0c8f70c000009',
  team_key: 'l.ncaa.org.mfoot-t.521',
  team_name: 'Kansas Jayhawks',
  trash_talk: [],
  waiting_events: [],
  has_processing: false,
  events: [],
  friends: [ '5102b17168a0c8f70c000010' ],
  points: { dedication: 0, passion: 0, knowledge: 0, overall: 0 } }
```

### `/v1/me/teams/[team_profile_id]`
* GET - gets the team profile

```javascript
{ _id: '5102b17168a0c8f70c000005',
  user_id: '5102b17168a0c8f70c000002',
  name: 'Mike Testing',
  team_id: '5102b17168a0c8f70c000008',
  team_key: 'l.ncaa.org.mfoot-t.522',
  team_name: 'Kansas St. Wildcats',
  __v: 0,
  trash_talk: [],
  waiting_events: [],
  has_processing: false,
  events: [],
  friends: [ '5102b17168a0c8f70c000007' ],
  points: { dedication: 5, passion: 3, knowledge: 2, overall: 10 } }
```

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
   * `friends_of` - [optional] restrict to only friends of a team_profile_id

```javascript
[ { _id: '5102b17168a0c8f70c000005',
    name: 'Mike Testing',
    points: { dedication: 5, passion: 3, knowledge: 2, overall: 10 } },
  { _id: '5102b17168a0c8f70c000007',
    name: 'Richard Testing',
    points: { dedication: 3, passion: 2, knowledge: 1, overall: 5 } } ]
```

### `/v1/leaderboard/teams/[team_id]/conference`
* GET - gets leaderboard based on conference

```javascript
[[ { _id: '5102b17168a0c8f70c000009',
    abbreviation: 'Kansas',
    nickname: 'Jayhawks',
    points: { dedication: 140, passion: 280, knowledge: 200, overall: 620 } },
  { _id: '5102b17168a0c8f70c000008',
    abbreviation: 'Kansas St.',
    nickname: 'Wildcats',
    points: { dedication: 50, passion: 250, knowledge: 100, overall: 400 } } ]
```

### `/v1/leaderboard/teams/[team_id]/league`
* GET - gets leaderboard based on league
 
```javascript
[ { _id: '5102b17168a0c8f70c000009',
    abbreviation: 'Kansas',
    nickname: 'Jayhawks',
    points: { dedication: 140, passion: 280, knowledge: 200, overall: 620 } },
  { _id: '5102b17168a0c8f70c000008',
    abbreviation: 'Kansas St.',
    nickname: 'Wildcats',
    points: { dedication: 50, passion: 250, knowledge: 100, overall: 400 } } ]
```

### `/v1/leaderboard/teams/[team_id]/breakdown`
* GET - gets points breakdown for this team 

```javascript
{ overall: 400, knowledge: 100, passion: 250, dedication: 50 }
```

### `/v1/leaderboard/teams/[team_id]/custom`
* GET - gets comparison between this team and another
  * `team_id` - team to compare against

```javascript
[ { _id: '5102b17168a0c8f70c000008',
    points: { dedication: 50, passion: 250, knowledge: 100, overall: 400 } },
  { _id: '5102b17168a0c8f70c000009',
    points: { dedication: 140, passion: 280, knowledge: 200, overall: 620 } } ]
```

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

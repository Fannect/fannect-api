# Fannect API
[![Build Status](https://secure.travis-ci.org/Fannect/fannect-mobileweb.png?branch=master)](https://travis-ci.org/Fannect/fannect-mobileweb)

This is the source for the Fannect core API.

# Environmental Variables
* MONGO_URL
* REDIS_URL
* CLOUDINARY_NAME
* CLOUDINARY_KEY
* CLOUDINARY_SECRET
* BING_IMAGE_KEY
* SENDGRID_USERNAME
* SENDGRID_PASSWORD
* PARSE_APP_ID
* PARSE_API_KEY

# REST Schema
This is based on [this video](http://blog.apigee.com/detail/restful_api_design) by apigee

## `/v1/me`
**GET** - get profile information for this user

```javascript
{ _id: '5102b17168a0c8f70c000002',
  email: 'testing1@fannect.me',
  password: 'hi',
  first_name: 'Mike',
  last_name: 'Testing',
  refresh_token: 'testingtoken',
  friends: [ '5102b17168a0c8f70c000004' ] }
```

**PUT** - update profile information
  * `first_name`
  * `last_name`

```javascript
{ status: 'success' }
```

## `/v1/me/verified`
**POST** - send verification request
  * any body content will be sent in the email
  
```javascript
{ status: 'success' }
```

## `/v1/me/teams`
**GET** - get all team profiles

```javascript
[ { _id: '5102b17168a0c8f70c000005',
    team_id: '5102b17168a0c8f70c000008',
    team_key: 'l.ncaa.org.mfoot-t.522',
    team_name: 'Kansas St. Wildcats',
    trash_talk: [],
    points: { dedication: 5, passion: 3, knowledge: 2, overall: 10 } } ]
```

**POST** - add a new team profile to the user
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

## `/v1/me/teams/[team_profile_id]`
**GET** - gets the team profile

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

## `/v1/me/invites`
**GET** - lists all friend invite

```javascript
[ { _id: '5102b17168a0c8f70c000020',
    name: 'Frank Testing',
    teams: [ 'Kansas St. Wildcats', 'Kansas Jayhawks' ] } ]
```

**POST** - accept a friend invite
  * `user_id` - accepts the user's invite

```javascript
{ status: 'success' }
```

**DELETE** - deletes a friend invite

## `/v1/me/games`
**GET** - lists all available games for this user

## `/v1/me/games/[game]`
**GET** - get current game state for this user

**PUT** - update current game state for this user

## `/v1/teams`
**POST** - upsert teams

```javascript
{ status: 'success', count: 621 }
```

## `/v1/teams/[team_id]`
**GET** - gets information about a team
* `content` - type of content to return, can only be `next_game` currently

## `/v1/teams/[team_id]/users`
**GET** - searches users of this team
* `q` _(optional)_ - query to filter users by
* `friends_of` _(optional)_ - restrict to only friends of a team_profile_id
* `skip` _(optional)_ - skips 'n' number of users
* `limit` _(optional)_ - limits the number of users returned
* `content` _(optional)_ - sets the content to return 
  * `standard` _(default)_ - only _id, name, and profile_image_url
  * `gameface` - adds `gameface_on` field

```javascript
[ { _id: '5102b17168a0c8f70c000021',
    name: 'Frank Testing',
    profile_image_url: 'images/empty_profile.jpg',
    gameface_on: false },
  { _id: '5102b17168a0c8f70c000005',
    name: 'Mike Testing',
    profile_image_url: 'images/empty_profile.jpg',
    gameface_on: false },
  { _id: '5102b17168a0c8f70c000007',
    name: 'Richard Testing',
    profile_image_url: 'images/empty_profile.jpg',
    gameface_on: true } ]
```

## `/v1/teams/[team_id]/groups`
**GET** - returns groups of this team
* `tags` _(optional)_ - tags to filter by
* `skip` _(optional)_ - skips 'n' number of users
* `limit` _(optional)_ - limits the number of users returned

**POST** - creates a group for this team
* `name` - name of the group
* `tags` - tags to associate with the group

## `/v1/groups/[group_id]`
**GET** - gets a group by `_id`

## `/v1/groups/[group_id]/teamprofiles`
**POST** - adds a team profile to a group
* `email` - email of the user to add

## `/v1/leaderboard/users/[team_id]`
**GET** - gets the overall leaderboard for a team
   * `friends_of` _(optional)_ - restrict to only friends of a team_profile_id

```javascript
[ { _id: '5102b17168a0c8f70c000005',
    name: 'Mike Testing',
    points: { dedication: 5, passion: 3, knowledge: 2, overall: 10 } },
  { _id: '5102b17168a0c8f70c000007',
    name: 'Richard Testing',
    points: { dedication: 3, passion: 2, knowledge: 1, overall: 5 } } ]
```

## `/v1/leaderboard/teams/[team_id]/conference`
**GET** - gets leaderboard based on conference

```javascript
{ conference_name: 'Big 12 Conference',
  teams: 
   [ { _id: '5102b17168a0c8f70c000009',
       location_name: 'Kansas',
       mascot: 'Jayhawks',
       full_name: 'Kansas Jayhawks',
       points: [Object] },
     { _id: '5102b17168a0c8f70c000008',
       location_name: 'Kansas St.',
       mascot: 'Wildcats',
       full_name: 'Kansas St. Wildcats',
       points: [Object] } ] }
```

## `/v1/leaderboard/teams/[team_id]/league`
**GET** - gets leaderboard based on league
 
```javascript
{ league_name: 'NCAA Men\'s Football Division 1A',
  teams: 
   [ { _id: '5102b17168a0c8f70c000009',
       location_name: 'Kansas',
       mascot: 'Jayhawks',
       full_name: 'Kansas Jayhawks',
       points: [Object] },
     { _id: '5102b17168a0c8f70c000008',
       location_name: 'Kansas St.',
       mascot: 'Wildcats',
       full_name: 'Kansas St. Wildcats',
       points: [Object] } ] }
```

## `/v1/leaderboard/teams/[team_id]/breakdown`
**GET** - gets points breakdown for this team 

```javascript
{ overall: 400, knowledge: 100, passion: 250, dedication: 50 }
```

## `/v1/leaderboard/teams/[team_id]/custom`
**GET** - gets comparison between this team and another
  * `team_id` - team to compare against

```javascript
[ { _id: '5102b17168a0c8f70c000008',
    points: { dedication: 50, passion: 250, knowledge: 100, overall: 400 } },
  { _id: '5102b17168a0c8f70c000009',
    points: { dedication: 140, passion: 280, knowledge: 200, overall: 620 } } ]
```

## `/v1/sports`
**GET** - lists available sports

```javascript
[ { sport_name: 'American Football', sport_key: '15003000' },
  { sport_name: 'Ice Hockey', sport_key: '15031000' } ]
```

## `/v1/sports/[sport_key]/leagues`
**GET** - lists available leagues for this sport

```javascript
[ { league_name: 'NCAA Men\'s Football Division 1A',
    league_key: 'l.ncaa.org.mfoot' } ]
```

## `/v1/sports/[sport_key]/leagues/[league_key]/teams`
**GET** - lists available teams for this league

```javascript
[ { abbreviation: 'Kansas',
    nickname: 'Jayhawks',
    team_key: 'l.ncaa.org.mfoot-t.521' },
  { abbreviation: 'Kansas St.',
    nickname: 'Wildcats',
    team_key: 'l.ncaa.org.mfoot-t.522' } ]
```

## `/v1/sports/[sport_key]/teams`
**GET** - searches available teams
* q - query to search by
* limit - number of teams to return
* skip - teams to skip

```javascript
[ { _id: '5102b17168a0c8f70c000009',
    location_name: 'Kansas',
    name: 'Jayhawks',
    full_name: 'Kansas Jayhawks' },
  { _id: '5102b17168a0c8f70c000008',
    location_name: 'Kansas St.',
    name: 'Wildcats',
    full_name: 'Kansas St. Wildcats' } ]
```

## `/v1/users/[user_id]` NOT IMPLEMENTED
**GET** - Gets user
* `is_friend_of` - user_id to check if this user is friends with

## `/v1/users/[user_id]/invite`
**POST** - Creates an invitation for specified user
* `inviter_user_id` - inviter's user id

```javascript
{ status: 'success' }
```

## `/v1/users/[user_id]/verified`
**PUT** - Creates an invitation for specified user
* `verified` - verified value to set (leave `null` to remove verification)

```javascript
{ status: 'success' }
```

## `/v1/teamprofiles`
**GET** - Gets most relevent team profile
* `user_id` - user_id of the team profile to get
* `friends_with` - **team_profile_id** of the user searching

```javascript
{ _id: '5102b17168a0c8f70c000021',
  user_id: '5102b17168a0c8f70c000020',
  name: 'Frank Testing',
  team_id: '5102b17168a0c8f70c000008',
  team_name: 'Kansas St. Wildcats',
  profile_image_url: 'images/empty_profile.jpg',
  team_image_url: 'images/empty_profile.jpg',
  is_college: true,
  friends: [],
  points: { dedication: 17, passion: 3, knowledge: 20, overall: 40 } }
```

## `/v1/teamprofiles/[team_profile_id]`
**GET** - Gets team profile
* `is_friend_of` - team_profile_id to check if this team_profile is friends with

```javascript
{ _id: '5102b17168a0c8f70c000005',
  user_id: '5102b17168a0c8f70c000002',
  name: 'Mike Testing',
  team_id: '5102b17168a0c8f70c000008',
  team_name: 'Kansas St. Wildcats',
  profile_image_url: 'images/empty_profile.jpg',
  team_image_url: 'images/empty_profile.jpg',
  is_college: true,
  points: { dedication: 5, passion: 3, knowledge: 2, overall: 10 } }
```

## `/v1/teamprofiles/[team_profile_id]/events`
**GET** - Gets events for team profile
* `skip` - events to skip
* `limit` - number of events to return

```javascript
[ { type: 'attendance_streak',
    meta: 
     { lat: '38.954229437679494',
       lng: '-95.25254333959168',
       checked_in: true },
    _id: '512061c95659b50200000053',
    points_earned: { dedication: 10 } },
  { type: 'guess_the_score',
    meta: { home_score: '71', away_score: '66', picked: true },
    _id: '5119c7ea0fcd5c0200000007',
    points_earned: { knowledge: 2 } },
  { type: 'game_face',
    meta: { face_on: true },
    _id: '5119c7ea0fcd5c0200000006',
    points_earned: { passion: 1 } } ]
```

## `/v1/images/me`
**PUT** - Updates this user's profile image
* `pull_twitter` - pull profile image from twitter

## `/v1/images/me/[team_profile_id]`
**PUT** - Updates the team image for this profile

## `/v1/images/bing`
**GET** - Search Bing for images
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

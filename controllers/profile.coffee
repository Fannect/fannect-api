express = require "express"
rest = require "request"
# ForceTK = require "../utils/forcetk"
sf = require "node-salesforce"

app = module.exports = express()

app.get "/", (req, res, next) -> 
   res.json 
      status: "success",
      message: "Fannect- a social network for sports fans"

app.get "/me", (req, res, next) ->
   # client = new ForceTK(req.session.auth)
   # console.log req.session.auth


   # conn = new sf.Connection
   #    oauth2:
   #       client_id: "3MVG9y6x0357Hlef0sJ1clNGWyYjGIN0fGQjmzawi2ojX6xQ_4MbJ7l1Xbl54iZcWCdFd5N1FTepUjq3DX12L"
   #       client_secret: "7701266349787425657"
   #       redirectUri: "https://login.salesforce.com/services/oauth2/success"
   #    instanceUrl: "https://na9-api.salesforce.com" #req.session.auth.instance_url
   #    accessToken: req.session.auth.access_token
   #    refreshToken: req.session.auth.refresh_token

   # conn.on "refresh", (access_token, res) ->
   #    console.log res, "res"
   #    req.session.auth.access_token = access_token
   conn = req.conn


   # conn.query "SELECT Id FROM User WHERE Id = 005E0000001jeZ4IAI", (err, data) ->
   #    return res.json data
   conn.sobject("User").retrieve req.session.user_id, (err, user) ->
      conn.sobject("ProfileTeam__c")
         .find({
            "Id": user.FavoriteTeamLookup__c
         }, {
            "ProfileTeam__c.Points__c": 1
            "ProfileTeam__c.Rank__c": 1
            "ProfileTeam__c.Roster__c": 1
            "ProfileTeam__c.TeamName__c": 1
            "ProfileTeam__c.Image__c": 1
         })
         .execute (err, profileTeam) ->
            res.json
               profile_image: user.ProfileImageURL__c
               team_image: profileTeam[0]?.Image__c
               roster: profileTeam[0]?.Roster__c or 0
               points: profileTeam[0]?.Points__c or 0
               rank: profileTeam[0]?.Rank__c or 0
               name: user.Name
               favorite_team: profileTeam[0]?.TeamName__c
               bio: user.Bio__c
               game_day_spot: user.GameDaySpot__c
               bragging_rights: user.BraggingRights__c

   # client.retrieve "User", req.session.user_id, (error, resp, body) ->

   #    return res.send body

   #    console.log "BODY:", b

   #    # console.log "resp", resp
   #    # console.log "body", body  

     
   #    res.json profileInfo

app.get "/me/invitations", (req, res, next) ->
   roster_fans = 
      [
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "profile-invitationProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "profile-invitationProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "profile-invitationProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "profile-invitationProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "profile-invitationProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "profile-invitationProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "profile-invitationProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "profile-invitationProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "profile-invitationProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         },
         {
            name: "Jeremy Eccles"
            team: "Sporting Kansas City"
            profile_url: "profile-invitationProfile.html?user=jeccles"
            profile_image_url: "/dev/Pic_Player@2x.png"
            roster: 100
            points: 100
            rank: 1
         }
      ]

   res.json invitations: roster_fans

app.get "/me/profile/selectSport", (req, res, next) ->
   sports = [ "basketball", "football" ]
   res.render "profile/selectSport", sports: sports

app.get "/me/profile/selectLeague", (req, res, next) ->
   sport = req.query.sport
   leagues = [ "NFL", "NCAA" ]
   res.render "profile/selectLeague", leagues: leagues

app.get "/me/profile/selectTeam", (req, res, next) ->
   league = req.query.league
   teams = [ "Arizona Cardinals", "Chicago Bears" ]
   res.render "profile/selectTeam", teams: teams
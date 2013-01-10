do ($ = jQuery, ko = window.ko, fc = window.fannect) ->

   class fc.viewModels.Profile
      constructor: (done) ->
         @editingImage = ko.observable false
         fc.user.get (err, data) =>
            @name = ko.observable data.name
            @team_image = ko.observable data.team_image or ""
            @profile_image = ko.observable data.profile_image or ""
            @favorite_team = ko.observable data.favorite_team
            @roster = ko.observable data.roster
            @points = ko.observable data.points
            @rank = ko.observable data.rank
            @bio = ko.observable data.bio
            @game_day_spot = ko.observable data.game_day_spot
            @bragging_rights = ko.observable data.bragging_rights
            done err, @

      changeUserImage: (data, e) ->
         @editingImage "profile"
         $("#changeProfileImagePopup").popup "open", 
            transition: "pop"
            positionTo: "window"

      changeTeamImage: (data, e) -> 
         @editingImage "team"
         $("#changeTeamImagePopup").popup "open", 
            transition: "pop"
            positionTo: "window"

      takeImage: (data, e) ->
         navigator.camera.getPicture @onImageDataSuccess, @phoneGapImageError, 
            quality: 80
            allowEdit: true
            destinationType: navigator.camera.DestinationType.DATA_URL
            sourceType: navigator.camera.PictureSourceType.CAMERA

      chooseImage: (data, e) ->
         navigator.camera.getPicture @onImageDataSuccess, @phoneGapImageError, 
            quality: 80
            allowEdit: true
            destinationType: navigator.camera.DestinationType.DATA_URL
            sourceType: navigator.camera.PictureSourceType.PHOTOLIBRARY

      chooseWebImage: () ->


      onImageDataSuccess: (image) ->
         # save image
         if @editingImage() == "profile"
            @profile_image(image)
            $("#changeProfileImagePopup").popup "close"
         else if @editingImage() == "team"
            @team_image(image)
            $("#changeTeamImagePopup").popup "close"

      cancelImagePicking: () ->
         @editingImage "none"

      phoneGapImageError: () ->
         $("#imageFailedPopup").popup "open", 
            transition: "pop"
            positionTo: "window"
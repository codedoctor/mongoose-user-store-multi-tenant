_ = require 'underscore-ext'
bcrypt = require 'bcryptjs'
Boom = require 'boom'
Hoek = require 'hoek'
mongooseRestHelper = require 'mongoose-rest-helper'
passgen = require 'passgen'
{isObjectId} = require 'mongodb-objectid-helper'

i18n = require '../i18n'
PageResult = require '../page-result'

require('date-utils') # NOTE DANGEROUS - FIND A BETTER METHOD SOMETIMES

fnUnprocessableEntity = (message = "",data) ->
  return Boom.create 422, message, data

###
Provides methods to interact with scotties.
###
module.exports = class UserMethods

  ###
  @TODO INVERT THIS LIKE EVERYWHERE ELSE
  ###
  UPDATE_FIELDS_FULL = ['username', 'description', 'displayName', 'identities','primaryEmail'
    'profileLinks', 'userImages', 'selectedUserImage', 'emails', 'roles', 'data', 'resourceLimits','onboardingState',
    'title','location','needsInit']

  ###
  Initializes a new instance of the {UserMethods} class.
  @param {Object} models A collection of models that can be used.
  ###
  constructor:(@models) ->
    Hoek.assert @models,i18n.assertModelsRequired
    Hoek.assert @models.User,i18n.assertUserInModelsRequired

  ###
  Retrieve all users for a specific _tenantId
  ###
  all:(_tenantId,options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    settings = 
        baseQuery:
          _tenantId : mongooseRestHelper.asObjectId _tenantId
        defaultSort: 'username'
        defaultSelect: null
        defaultCount: 50
    mongooseRestHelper.all @models.User,settings,options, cb


  ###
  Retrieves a user by it's id.
  ###
  get: (userId,options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorUserIdRequired) unless userId
    mongooseRestHelper.getById @models.User,userId,null,options, cb

  ###
  Retrieves users by passing a list of id's, which can be string or objectIds
  ###
  getByIds:(idList = [], options =  {}, cb = ->) =>
    idList = _.map idList, (x) -> mongooseRestHelper.asObjectId(x)

    if _.isFunction(options)
      cb = options 
      options = {}

    @models.User.find({}).where('_id').in(idList).exec (err, users) =>
      return cb err if err
      users or= []

      cb null, new PageResult(users, users.length, 0, users.length)

  ###
  Retrieves users by passing a list of usernames.
  @param {[String]} usernames an array of usernames. Case insensitive
  @param {Object} options a set of options, which can be null
  @param {Function} cb a callback that is invoked after completion of this method.
  @option options [String] select the space separated fields to return, which default to all.
  ###
  getByUsernames:(_tenantId,usernames = [],options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId
    usernames = _.map usernames, (x) -> x.toLowerCase()

    query = @models.User.find({_tenantId : _tenantId}).where('username').in(usernames)
    query = query.select(options.select) if options.select && options.select.length > 0

    query.exec (err, users) =>
      return cb err if err
      users or= []

      cb null, new PageResult(users, users.length, 0, usernames.length)


  ###
  Returns a list of users who match q. In this version we do a straight user name match.
  @param {String} q a search string.
  @param {Object} options a set of options, which can be null
  @param {Function} cb a callback that is invoked after completion of this method.
  @option options [Integer] limit the maximum number of results to return, defaults to 10.
  @option options [String] sortOrder the sort order in mongodb syntax, which defaults to 'username'.
  @option options [String] select the space separated fields to return, which default to '_id username displayName selectedUserImage'.
  ###
  lookup: (_tenantId,q,options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    q = (q || '').toLowerCase().trim()
    _tenantId = mongooseRestHelper.asObjectId _tenantId

    options.limit or= 10
    options.sortOrder or= 'username'
    options.select or= '_id username displayName selectedUserImage'

    r = new RegExp("^#{q}")

    #
    @models.User.find({_tenantId : _tenantId,username : r }).select(options.select).sort(options.sortOrder).limit(options.limit).exec (err, users) =>
      return cb err if err
      users or= []

      cb null, new PageResult(users, users.length, 0, users.length)

  getByName: (_tenantId,name,options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId
    return cb fnUnprocessableEntity( i18n.errorNameRequired) unless name

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId
    name = name.toLowerCase()
    @models.User.findOne {_tenantId : _tenantId,username: name }, (err, user) =>
      return cb err if err
      cb null, user

  getByPrimaryEmail: (_tenantId,email, options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId
    return cb fnUnprocessableEntity( i18n.errorEmailRequired) unless email

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId
    email = email.toLowerCase()
    @models.User.findOne {_tenantId : _tenantId,primaryEmail: email} , (err, user) =>
      return cb err if err
      cb null, user

  getByNameOrId: (_tenantId,nameOrId,options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}


    if isObjectId(nameOrId)
      @get nameOrId, cb
    else
      @getByName _tenantId,nameOrId, cb

  patch: (_tenantId,usernameOrId, obj = {},options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId
    @getByNameOrId _tenantId,usernameOrId, (err, user) =>
      # CHECK ACCESS RIGHTS. If actor is not the creator
      return cb err if err
      return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindUser} #{usernameOrId}") unless user

      _.extendFiltered user, UPDATE_FIELDS_FULL, obj
      user.save (err) =>
        return cb err if err

        if obj.password
          @setPassword _tenantId,usernameOrId,obj.password, {}, (err,user2) =>
            return cb err if err
            cb null, user
        else
          cb null, user

  delete: (_tenantId,usernameOrId,options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId
    @getByNameOrId _tenantId,usernameOrId, (err, user) =>

      return cb err if err
      return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindUser} #{usernameOrId}") unless user

      return cb null if user.isDeleted

      user.isDeleted = true
      user.deletedAt = new Date()
      user.save (err) =>
        return cb err if err
        cb null, user

  destroy: (_tenantId,usernameOrId, options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    @getByNameOrId _tenantId,usernameOrId, {}, (err, user) =>
      return cb err if err
      return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindUser} #{usernameOrId}") unless user

      user.remove (err) =>
        return cb err if err
        cb null, user

  setPassword: (_tenantId,usernameOrId, password,options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    @getByNameOrId _tenantId,usernameOrId, {}, (err, user) =>
      return cb err if err
      # @TODO don't return url here
      return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindUser} #{usernameOrId}") unless user && !user.isDeleted

      @_hashPassword password, (err, hash) =>
        return cb err if err
        user.password = hash

        user.save (err) =>
          return cb err if err
          cb null, user

  ###
  Looks up a user by username or email.
  ###
  findUserByUsernameOrEmail: (_tenantId,usernameOrEmail, options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId
    usernameOrEmail = usernameOrEmail.toLowerCase()

    @models.User.findOne {_tenantId : _tenantId,username: usernameOrEmail} , (err, user) =>
      return cb err if err
      return cb(null, user) if user

      # Be smart, only try email if we have something that looks like an email.

      @models.User.findOne {_tenantId : _tenantId,primaryEmail: usernameOrEmail }, (err, user) =>
        return cb err if err
        cb(null, user)

  ###
  Looks up the user, if found validates against password.
  cb(err) in case of non password error.
  cb(null, user) in case of user not found, password not valid, or valid user
  ###
  validateUserByUsernameOrEmail: (_tenantId,usernameOrEmail, password, options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId
    usernameOrEmail = usernameOrEmail.toLowerCase()
    
    @findUserByUsernameOrEmail _tenantId,usernameOrEmail, (err, user) =>
      return cb err if err
      return cb null, null unless user
      bcrypt.compare password, user.password, (err, res) =>
        return cb err if err
        return cb null, null unless res
        cb null, user

  #verifyPassword: (hash)
  #bcrypt.compare("B4c0/\/", hash, function(err, res)

  _hashPassword: (password, cb) =>
    bcrypt.genSalt 10, (err, salt) =>
      return cb err if err
      bcrypt.hash password, salt, (err, hash) =>
        return cb err if err
        cb(null, hash)

  ###
  Creates a new user.
  ###
  create: (_tenantId,objs = {},options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId

    _.defaults objs, {username : null, primaryEmail : null , password : null}
    objs.primaryEmail = objs.email if objs.email && !objs.primaryEmail
    delete objs.email
    objs._tenantId = _tenantId

    user = new @models.User objs
    user.emails = [objs.primaryEmail] if objs.primaryEmail

    ###
    var gravatar = require('gravatar');
    var url = gravatar.url('emerleite@gmail.com', {s: '200', r: 'pg', d: '404'});

    ###
    #email
    @_hashPassword objs.password, (err, hash) =>
      return cb err if err
      user.password = hash

      user.save (err) =>
        return cb err if err

        cb(null, user)


  ###
  Gets or creates a user for a given provider/profile combination.
  @param {String} provider a provider string like "facebook" or "twitter".
  @param {String} v1 the key or access_token, depending on the type of provider
  @param {String} v2 the secret or refresh_token, depending on the type of provider
  @param {Object} profile The profile as defined here: http://passportjs.org/guide/user-profile.html
  ###
  getOrCreateUserFromProvider: (_tenantId,provider, v1, v2, profile,options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    return cb fnUnprocessableEntity( i18n.errorIdWithinProfileRequired) unless profile && profile.id

    _tenantId = mongooseRestHelper.asObjectId _tenantId

    #console.log "PROFILE #{JSON.stringify(profile)} ENDPROFILE" 

    identityQuery =
      _tenantId : _tenantId
      'identities.provider': provider
      'identities.key': profile.id

    isNew = false
    @models.User.findOne identityQuery , (err, user) =>
      return cb err if err

      if user
        for identity in user.identities
          if identity.provider is provider
            identity.v1 = v1
            identity.v2 = v2
        user.save (err) =>
          return cb err if err
          cb null, user, isNew : isNew

      else
        isNew = true

        isUserNameValid = true

        pusername = profile.username || "fb#{profile.id}"

        @models.User.findOne {_tenantId : _tenantId,username : pusername} , (err,userXX) =>
          return cb err if err
          isUserNameValid = !userXX  #valid if it does not exist


          # PROFILE DATA:
          # profile.emails [{value,type}]
          # profile.name {familyName, givenName, middleName}
          # FB,Twitter: profile.username
          # FB: gender (male, female) => fb
          # FB: profileUrl
          # Twitter: .photos[0] -> URL

          # TWITTER MOCK:
          # {"id_str":"6253282","id":6253282,"profile_text_color":"437792","created_at":"Wed May 23 06:01:13 +0000 2007","contributors_enabled":true,"follow_request_sent":null,"lang":"en","listed_count":10154,"profile_sidebar_border_color":"0094C2","show_all_inline_media":false,"friends_count":34,"utc_offset":-28800,"location":"San Francisco, CA","name":"Twitter API","profile_background_tile":false,"profile_sidebar_fill_color":"a9d9f1","profile_image_url_https":"https:\/\/si0.twimg.com\/profile_images\/1438634086\/avatar_normal.png","protected":false,"geo_enabled":true,"following":null,"default_profile_image":false,"statuses_count":3252,"is_translator":false,"favourites_count":22,"profile_background_color":"e8f2f7",
          #  "description":"The Real Twitter API. I tweet about API changes, service issues and happily answer questions about Twitter and our API. Do not get an answer? It is on my website.",
          # "time_zone":"Pacific Time (US & Canada)","screen_name":"twitterapi",
          # "profile_background_image_url":"http:\/\/a0.twimg.com\/profile_background_images\/229557229\/twitterapi-bg.png",
          # "profile_image_url":"http:\/\/a0.twimg.com\/profile_images\/1438634086\/avatar_normal.png",
          # "profile_link_color":"0094C2",
          # "profile_background_image_url_https":"https:\/\/si0.twimg.com\/profile_background_images\/229557229\/twitterapi-bg.png",
          # "followers_count":931299,
          # "status":{"in_reply_to_status_id_str":null,"in_reply_to_user_id_str":null,
          #           "retweeted":false,"coordinates":null,"in_reply_to_screen_name":null,"created_at":"Tue Feb 14 23:39:43 +0000 2012","possibly_sensitive":false,"contributors":null,"in_reply_to_status_id":null,"entities":{"urls":[{"display_url":"tmblr.co\/ZgBqayGQi3ls","indices":[106,126],"expanded_url":"http:\/\/tmblr.co\/ZgBqayGQi3ls","url":"http:\/\/t.co\/cOzUfFNW"}],"user_mentions":[],"hashtags":[]},"geo":null,"in_reply_to_user_id":null,"place":null,"favorited":false,"truncated":false,"id_str":"169566520693882882","id":169566520693882882,"retweet_count":82,"text":"Photo Upload Issue - Some users may be experiencing an issue when uploading a photo. Our engineers are... http:\/\/t.co\/cOzUfFNW"},
          # "default_profile":false,
          # "notifications":null,
          # "url":"http:\/\/dev.twitter.com",
          # "profile_use_background_image":true,"verified":true}';
          # FACEBOOK MOCK
          ###
          { "_json" : { "email" : "martin@wawrusch.com",
      "favorite_athletes" : [ { "id" : "69025400418",
            "name" : "Kobe Bryant"
          },
          { "id" : "34778334225",
            "name" : "Kelly Slater"
          }
        ],
      "favorite_teams" : [ { "id" : "144917055340",
            "name" : "LA Lakers"
          } ],
      "first_name" : "Martin",
      "gender" : "male",
      "id" : "679841881",
      "last_name" : "Wawrusch",
      "link" : "http://www.facebook.com/martinw",
      "locale" : "en_US",
      "location" : { "id" : "109434625742337",
          "name" : "West Hollywood, California"
        },
      "name" : "Martin Wawrusch",
      "timezone" : -8,
      "updated_time" : "2012-10-31T18:05:42+0000",
      "username" : "martinw",
      "verified" : true
    },
  "_raw" : "{\"id\":\"679841881\",\"name\":\"Martin Wawrusch\",\"first_name\":\"Martin\",\"last_name\":\"Wawrusch\",\"link\":\"http:\\/\\/www.facebook.com\\/martinw\",\"username\":\"martinw\",\"location\":{\"id\":\"109434625742337\",\"name\":\"West Hollywood, California\"},\"favorite_teams\":[{\"id\":\"144917055340\",\"name\":\"LA Lakers\"}],\"favorite_athletes\":[{\"id\":\"69025400418\",\"name\":\"Kobe Bryant\"},{\"id\":\"34778334225\",\"name\":\"Kelly Slater\"}],\"gender\":\"male\",\"email\":\"martin\\u0040wawrusch.com\",\"timezone\":-8,\"locale\":\"en_US\",\"verified\":true,\"updated_time\":\"2012-10-31T18:05:42+0000\"}",
  "displayName" : "Martin Wawrusch",
  "emails" : [ { "value" : "martin@wawrusch.com" } ],
  "gender" : "male",
  "id" : "679841881",
  "name" : { "familyName" : "Wawrusch",
      "givenName" : "Martin"
    },
  "profileUrl" : "http://www.facebook.com/martinw",
  "provider" : "facebook",
  "username" : "martinw"
}

          ###
          # TODO: Check for existance here, try to keep username
          user = new @models.User
          user._tenantId = _tenantId
          user.username = (if isUserNameValid then pusername else pusername + passgen.create(4)).toLowerCase()
          user.displayName = profile.displayName || user.username || pusername
          user.data =  {} #profile._json
          user.description = profile.description || ''
          user.title = ""

          # Handling Images
          # Filter out all the images first
          images = []
          images = profile.photos if provider is 'twitter' && profile.photos && _.isArray(profile.photos)
          images.push "https://graph.facebook.com/#{profile.username || profile.id}/picture" if profile.username && provider is "facebook"

          # TODO: Add gravatar perhaps as well?
          for imageUrl in images
            user.userImages.push # new @models.UserImage
              url : imageUrl
              # TODO: Add type here.

          # Twitter first
          if profile.profile_image_url && profile.profile_image_url.length > 5
            user.selectedUserImage = profile.profile_image_url
          else
            # Set the selected user image, be radical about it.
            user.selectedUserImage = images[0] if images.length > 0

          if provider is "facebook" && profile.profileUrl



            user.profileLinks.push # new @models.UserProfile
              linkUrl : profile.profileUrl
              linkIdentifier: profile.id
              provider : provider
              linkType : 'social'
              linkSubType: 'primary'
              caption : "Facebook"
              isPublic: true

          if provider is "twitter" 
            user.profileLinks.push # new @models.UserProfile
              linkUrl : "https://twitter.com/#{profile.username}"
              linkIdentifier: profile.username
              provider : provider
              linkType : 'social'
              linkSubType: 'primary'
              caption : "Twitter"
              isPublic: true

          emails = []
          if profile.emails && _.isArray(profile.emails)
            profile.emails = _.filter profile.emails, (x) ->x.value && x.value.length > 3

            emails = _.map(profile.emails, (x) -> x.value)



          # emails
          for email in emails
            user.emails.push new #@models.Email
              email : email.toLowerCase()
              isVerified : true # We assume so, because it comes from a social network
              sendNotifications : false # Dunno what this is good for.
          user.primaryEmail = user.emails[0].email.toLowerCase() if user.emails.length > 0

          user.location = profile._json?.location?.name
          user.needsInit = !profile.username || !user.primaryEmail || user.primaryEmail.toLowerCase().indexOf("facebook.com") > 0
          
          #user.needsInit = true

          user.gender = profile.gender
          user.timezone = profile._json?.timezone
          user.locale = profile._json?.locale
          user.verified = profile._json?.verified
          user.roles = ['user-needs-setup']

          newIdentity = #new @models.UserIdentity
            provider: provider
            key: profile.id
            v1 : v1
            v2 : v2
            providerType: "oauth"
            username : user.username
            displayName : user.displayName
            profileImage : user.selectedUserImage
          user.identities.push newIdentity
            # More stuff
          user.save (err) =>
            return cb err if err
            cb null, user, isNew : isNew,newIdentity

  _usernameFromProfile: (profile) =>
    profile.username || ''

  _displayNameFromProfile: (profile) =>
    return profile.displayName if profile.displayName
    return "#{profile.name.givenName} #{profile.name.familyName}" if profile.name && profile.name.givenName && profile.name.familyName
    return profile.name.familyName if profile.name && profile.name.familyName
    profile.username

  _profileImageFromProfile: (profile) =>
    return "https://graph.facebook.com/#{profile.username}/picture" if profile.username && profile.provider is "facebook"
    return profile.photos[0].value if profile.provider is 'twitter' && profile.photos && _.isArray(profile.photos) && profile.photos.length > 0
    if profile.provider is 'instagram'
      try
        raw = JSON.parse profile._raw
        return raw.data.profile_picture
      catch e
        return null

    if profile.provider is 'foursquare'
      try
        raw = JSON.parse profile._raw
        return raw.response.user.photo
      catch e
        return null
    
    null


  ###
  Adds an identity to an existing user. In this version, it replaces an 
  existing provider of the same type.
  @param {String/ObjectId} userId the id of the user to add this identity to.
  @param {String} provider a provider string like "facebook" or "twitter".
  @param {String} v1 the key or access_token, depending on the type of provider
  @param {String} v2 the secret or refresh_token, depending on the type of provider
  @param {Object} profile The profile as defined here: http://passportjs.org/guide/user-profile.html
  ###
  addIdentityToUser: (userId,provider, v1, v2, profile,options = {}, cb = ->) =>
    if _.isFunction(options)
      cb = options 
      options = {}

    return cb fnUnprocessableEntity( i18n.errorUserIdRequired) unless userId
    return cb fnUnprocessableEntity( i18n.errorProviderRequired) unless provider
    return cb fnUnprocessableEntity( i18n.errorV1Required) unless v1
    return cb fnUnprocessableEntity( i18n.errorProfileRequired) unless profile
    return cb fnUnprocessableEntity( i18n.errorIdWithinProfileRequired) unless profile && profile.id

    userId = mongooseRestHelper.asObjectId userId
    provider = provider.toLowerCase()

    @models.User.findOne _id: userId , (err, user) =>
      return cb err if err
      return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindUser} #{userId}") unless user

      existing = _.find user.identities, (x) -> x.provider is provider
      existing.remove() if existing

      newIdentity = #new @models.UserIdentity
        provider: provider
        key: profile.id
        v1 : v1
        v2 : v2
        providerType: "oauth"
        username : @_usernameFromProfile(profile)
        displayName : @_displayNameFromProfile(profile)
        profileImage : @_profileImageFromProfile(profile)
      
      user.identities.push newIdentity
      user.save (err) =>
        return cb err if err
        cb null, user,newIdentity

  removeIdentityFromUser:(userId,identityId,options = {},cb = ->) =>
    if _.isFunction(options)
      cb = options 
      options = {}

    return cb fnUnprocessableEntity( i18n.errorUserIdRequired) unless userId
    return cb fnUnprocessableEntity( i18n.errorIdentityIdRequired) unless identityId

    userId = mongooseRestHelper.asObjectId userId
    identityId = mongooseRestHelper.asObjectId identityId

    @models.User.findOne _id: userId , (err, user) =>
      return cb err if err
      return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindUser} #{userId}") unless user

      existing = user.identities.id(identityId)
      existing.remove() if existing

      user.save (err) =>
        return cb err if err
        cb null, user

  addRoles:(userId,roles,options = {},cb = ->) =>
    if _.isFunction(options)
      cb = options 
      options = {}

    roles = [roles] if _.isString(roles)

    return cb fnUnprocessableEntity( i18n.errorUserIdRequired) unless email
    return cb fnUnprocessableEntity( i18n.errorRolesRequired) unless roles && _.isArray(roles) && roles.length > 0

    userId = mongooseRestHelper.asObjectId userId

    @models.User.findOne _id: userId , (err, user) =>
      return cb err if err
      return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindUser} #{userId}") unless user
      user.roles = _.union(user.roles || [],roles)
      user.save (err) =>
        return cb err if err
        cb null,user.roles, user

  removeRoles:(userId,roles,options = {},cb = ->) =>
    if _.isFunction(options)
      cb = options 
      options = {}

    roles = [roles] if _.isString(roles)

    return cb fnUnprocessableEntity( i18n.errorUserIdRequired) unless email
    return cb fnUnprocessableEntity( i18n.errorRolesRequired) unless roles && _.isArray(roles) && roles.length > 0

    userId = mongooseRestHelper.asObjectId userId

    @models.User.findOne _id: userId , (err, user) =>
      return cb err if err
      return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindUser} #{userId}") unless user
      user.roles = _.difference(user.roles || [],roles)
      user.save (err) =>
        return cb err if err
        cb null,user.roles, user

  resetPasswordTokenLength = 10

  resetPassword: (_tenantId,email,options = {},cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    return cb fnUnprocessableEntity( i18n.errorEmailRequired) unless email

    @getByPrimaryEmail _tenantId,email, (err,user) =>
      return cb err if err
      return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindUser} #{email}") unless user

      newToken = passgen.create(resetPasswordTokenLength) + user._id.toString() + passgen.create(resetPasswordTokenLength)
      user.resetPasswordToken =
        token: newToken
        validTill : (new Date()).add( days : 1)
      console.log "E"
      user.save (err) =>
        console.log "F"
        console.log "G"
        cb null,user,newToken

  #p0qEeKBoh25031326eefa65c0000000006TWlhZKbLjn
  resetPasswordToken: (_tenantId,token,password,options = {},cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    return cb fnUnprocessableEntity( i18n.errorTokenRequired) unless token
    return cb fnUnprocessableEntity( i18n.errorPasswordRequired) unless password

    userId = token.substr(resetPasswordTokenLength,token.length - 2 * resetPasswordTokenLength)
    userId = mongooseRestHelper.asObjectId userId
    @_hashPassword password, (err, hash) =>
      return cb err if err
      @models.User.findOne _id: userId , (err, user) =>
        return cb err if err
        return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindUser} #{userId}") unless user

        return cb fnUnprocessableEntity( i18n.errorTokenRequired) unless user.resetPasswordToken
        return cb fnUnprocessableEntity( i18n.errorTokenInvalid) unless (user.resetPasswordToken.token || '').toLowerCase() is token.toLowerCase()
        return cb fnUnprocessableEntity( i18n.errorValidTillFailed) unless user.resetPasswordToken.validTill && user.resetPasswordToken.validTill.isAfter(new Date())

        user.resetPasswordToken = null
        #user.markModified 'resetPasswordToken'
        user.password = hash
        user.save (err) =>
          return cb err if err
          cb null,user


  addEmail:(userId,email,isValidated,options = {},cb = ->) =>
    if _.isFunction(options)
      cb = options 
      options = {}

    return cb fnUnprocessableEntity( i18n.errorUserIdRequired) unless userId
    return cb fnUnprocessableEntity( i18n.errorEmailRequired) unless email
    userId = mongooseRestHelper.asObjectId userId

    @models.User.findOne _id: userId , (err, user) =>
      return cb err if err
      return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindUser} #{userId}") unless user

      user.emails = _.union(user.emails || [],[email])
      user.save (err) =>
        return cb err if err
        cb null,user.emails, user

  removeEmail:(userId,email,options = {},cb = ->) =>
    if _.isFunction(options)
      cb = options 
      options = {}

    return cb fnUnprocessableEntity( i18n.errorUserIdRequired) unless userId
    return cb fnUnprocessableEntity( i18n.errorEmailRequired) unless email
    userId = mongooseRestHelper.asObjectId userId

    @models.User.findOne _id: userId , (err, user) =>
      return cb err if err
      return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindUser} #{userId}") unless user
      user.emails = _.difference(user.emails || [],[email])
      user.save (err) =>
        return cb err if err
        cb null,user.emails, user


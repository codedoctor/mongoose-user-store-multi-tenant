_ = require 'underscore-ext'
errors = require 'some-errors'
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId
bcrypt = require 'bcryptjs'
passgen = require 'passgen'
async = require 'async'
i18n = require '../i18n'

###
Provides methods to interact with scotties.
###
module.exports = class AdminMethods

  ###
  Initializes a new instance of the @see ScottyMethods class.
  @param {Object} models A collection of models that can be used.
  ###
  constructor:(@models, @users) ->
    throw new Error "models parameter is required" unless @models
    throw new Error "users parameter is required" unless @users

  ###
  Sets up an account ready for use.
  ###
  setup: (_tenantId,appName, username, email, password,scopes = [], clientId = null, secret = null,options = {}, cb = ->) =>
    return cb new Error "_tenantId parameter is required." unless _tenantId
    return cb new Error "appName parameter is required." unless appName
    return cb new Error "username parameter is required." unless username
    return cb new Error "email parameter is required." unless email
    return cb new Error "password parameter is required." unless password

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = new ObjectId _tenantId.toString()

    adminUser =
      _tenantId : _tenantId
      username : username
      password : password
      displayName: 'ADMIN'
      roles: ['admin','serveradmin']
      email : email

    # @TODO Check if user exists, if so, do nothing

    @users.create _tenantId,adminUser,{}, (err, user) =>
      return cb err if err
      cb null, user

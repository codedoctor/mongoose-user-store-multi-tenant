_ = require 'underscore-ext'
errors = require 'some-errors'
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId
bcrypt = require 'bcryptjs'
mongooseRestHelper = require 'mongoose-rest-helper'
i18n = require '../i18n'

{isObjectId} = require 'mongodb-objectid-helper'

###
Provides methods to interact with scotties.
###
module.exports = class EntityMethods
  ###
  Initializes a new instance of the @see ScottyMethods class.
  @param {Object} models A collection of models that can be used.
  ###
  constructor:(@models) ->
    throw new Error "models parameter is required" unless @models

  ###
  Looks up a user or organization by id. Users are first.
  ###
  get: (id,options = {}, cb = ->) =>
    return cb new Error "id parameter is required." unless id
    mongooseRestHelper.getById @models.User,id,null,options, (err,item) =>
      return cb err if err
      return cb null, item if item
      mongooseRestHelper.getById @models.Organization,id,null,options,cb


  ###
  @TODO resthelper implementation
  ###
  getByName: (_tenantId,name,options = {}, cb = ->) =>
    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = new ObjectId _tenantId.toString()
    @models.User.findOne {_tenantId : _tenantId, username: name} , (err, item) =>
      return cb err if err
      return cb null, item if item
      @models.Organization.findOne {_tenantId : _tenantId,name: name }, (err, item) =>
        return cb err if err
        cb null, item

  ###
  @TODO resthelper implementation
  ###
  getByNameOrId: (_tenantId,nameOrId, options = {},cb = ->) =>
    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = new ObjectId _tenantId.toString()

    if isObjectId(nameOrId)
      @get nameOrId, options, cb
    else
      @getByName _tenantId,nameOrId, options, cb


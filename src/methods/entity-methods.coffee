_ = require 'underscore-ext'
errors = require 'some-errors'
PageResult = require('simple-paginator').PageResult
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId
bcrypt = require 'bcryptjs'
mongooseRestHelper = require 'mongoose-rest-helper'

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
  getByName: (accountId,name,options = {}, cb = ->) =>
    if _.isFunction(options)
      cb = options 
      options = {}

    accountId = new ObjectId accountId.toString()
    @models.User.findOne {accountId : accountId, username: name} , (err, item) =>
      return cb err if err
      return cb null, item if item
      @models.Organization.findOne {accountId : accountId,name: name }, (err, item) =>
        return cb err if err
        cb null, item

  ###
  @TODO resthelper implementation
  ###
  getByNameOrId: (accountId,nameOrId, options = {},cb = ->) =>
    if _.isFunction(options)
      cb = options 
      options = {}

    accountId = new ObjectId accountId.toString()

    if isObjectId(nameOrId)
      @get nameOrId, options, cb
    else
      @getByName accountId,nameOrId, options, cb


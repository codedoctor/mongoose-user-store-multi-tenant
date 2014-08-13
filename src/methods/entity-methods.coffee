_ = require 'underscore-ext'
mongooseRestHelper = require 'mongoose-rest-helper'
i18n = require '../i18n'
Hoek = require 'hoek'
Boom = require 'boom'

{isObjectId} = require 'mongodb-objectid-helper'

fnUnprocessableEntity = (message = "",data) ->
  return Boom.create 422, message, data

###
Provides methods to interact with scotties.
###
module.exports = class EntityMethods
  ###
  Initializes a new instance of the @see ScottyMethods class.
  @param {Object} models A collection of models that can be used.
  ###
  constructor:(@models) ->
    Hoek.assert @models,i18n.assertModelsRequired

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
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId
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
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId

    if isObjectId(nameOrId)
      @get nameOrId, options, cb
    else
      @getByName _tenantId,nameOrId, options, cb


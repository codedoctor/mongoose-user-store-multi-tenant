_ = require 'underscore-ext'
mongooseRestHelper = require 'mongoose-rest-helper'
i18n = require '../i18n'
Hoek = require 'hoek'
Boom = require 'boom'

{isObjectId} = require 'mongodb-objectid-helper'


###
Provides methods to interact with entities.
###
module.exports = class EntityMethods
  ###
  Initializes a new instance of the @see EntityMethods class.
  @param {Object} models A collection of models that can be used.
  ###
  constructor:(@models) ->
    Hoek.assert @models,i18n.assertModelsRequired
    Hoek.assert @models.User,i18n.assertUserInModelsRequired
    Hoek.assert @models.Organization,i18n.assertOrganizationInModelsRequired

  ###
  Looks up a user or organization by id. Users are first.
  ###
  get: (userIdOrOrganizationId,options = {}, cb = ->) =>
    return cb Boom.badRequest( i18n.errorUserIdOrOrganizationIdRequired) unless userIdOrOrganizationId

    mongooseRestHelper.getById @models.User,userIdOrOrganizationId,null,options, (err,item) =>
      return cb err if err
      return cb null, item if item
      mongooseRestHelper.getById @models.Organization,userIdOrOrganizationId,null,options,cb


  getByName: (_tenantId,name,options = {}, cb = ->) =>
    return cb Boom.badRequest( i18n.errorTenantIdRequired) unless _tenantId
    return cb Boom.badRequest( i18n.errorNameRequired) unless name

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

  getByNameOrId: (_tenantId,nameOrId, options = {},cb = ->) =>
    return cb Boom.badRequest( i18n.errorTenantIdRequired) unless _tenantId
    return cb Boom.badRequest( i18n.errorNameOrIdRequired) unless nameOrId

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId

    if isObjectId(nameOrId)
      @get nameOrId, options, cb
    else
      @getByName _tenantId,nameOrId, options, cb


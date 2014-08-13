_ = require 'underscore-ext'
mongooseRestHelper = require 'mongoose-rest-helper'

i18n = require '../i18n'
Hoek = require 'hoek'
Boom = require 'boom'

{isObjectId} = require 'mongodb-objectid-helper'

fnUnprocessableEntity = (message = "",data) ->
  return Boom.create 422, message, data

###
Provides methods to interact with organizations.
###
module.exports = class OrganizationMethods
  UPDATE_EXCLUDEFIELDS = ['_id','createdByUserId','createdAt']
  ###
  Initializes a new instance of the @see ScottyMethods class.
  @param {Object} models A collection of models that can be used.
  ###
  constructor:(@models) ->
    Hoek.assert @models,i18n.assertModelsRequired
    Hoek.assert @models.Organization,i18n.assertOrganizationInModelsRequired

  all: (_tenantId, options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    settings = 
        baseQuery:
          _tenantId : mongooseRestHelper.asObjectId _tenantId
        defaultSort: 'name'
        defaultSelect: null
        defaultCount: 1000
    mongooseRestHelper.all @models.Organization,settings,options, cb

  ###
  Looks up an organization by id.
  ###
  get: (organizationId, options =  {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorOrganizationIdRequired) unless organizationId

    mongooseRestHelper.getById @models.Organization,organizationId,null,options, cb


  ###
  Completely destroys an organization.
  ###
  destroy: (organizationId,options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorOrganizationIdRequired) unless organizationId
    settings = {}
    mongooseRestHelper.destroy @models.Organization,organizationId, settings,{}, cb

  getByName: (_tenantId, name, options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId
    return cb fnUnprocessableEntity( i18n.errorNameRequired) unless name

    if _.isFunction(options)
      cb = options 
      options = {}

    @models.Organization.findOne name: name , (err, item) =>
      return cb err if err
      cb null, item

  getByNameOrId: (_tenantId, nameOrId, options = {},cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId
    return cb fnUnprocessableEntity( i18n.errorNameOrIdRequired) unless nameOrId

    if _.isFunction(options)
      cb = options 
      options = {}

    if isObjectId(nameOrId)
      @get nameOrId, cb
    else
      @getByName nameOrId, cb

  ###
  Patches an organization
  ###
  patch: (organizationId, obj = {}, options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorOrganizationIdRequired) unless organizationId
    settings =
      exclude : UPDATE_EXCLUDEFIELDS
    mongooseRestHelper.patch @models.Organization,organizationId, settings, obj, options, cb


  ###
  Creates a new organization.
  ###
  create: (_tenantId, objs = {},options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    objs._tenantId = mongooseRestHelper.asObjectId _tenantId

    settings = {}
    mongooseRestHelper.create @models.Organization,settings,objs,options,cb



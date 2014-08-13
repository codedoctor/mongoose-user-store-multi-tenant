_ = require 'underscore-ext'
errors = require 'some-errors'
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId
mongooseRestHelper = require 'mongoose-rest-helper'
i18n = require '../i18n'

{isObjectId} = require 'mongodb-objectid-helper'


###
Provides methods to interact with scotties.
###
module.exports = class OrganizationMethods
  UPDATE_EXCLUDEFIELDS = ['_id','createdByUserId','createdAt']
  ###
  Initializes a new instance of the @see ScottyMethods class.
  @param {Object} models A collection of models that can be used.
  ###
  constructor:(@models) ->
    throw new Error "models parameter is required" unless @models

  all: (_tenantId, options = {}, cb = ->) =>
    return cb new Error "_tenantId parameter is required." unless _tenantId

    settings = 
        baseQuery:
          _tenantId : mongooseRestHelper.asObjectId _tenantId
        defaultSort: 'name'
        defaultSelect: null
        defaultCount: 1000
    mongooseRestHelper.all @models.Organization,settings,options, cb

  ###
  Looks up a user by id.
  ###
  get: (organizationId, options =  {}, cb = ->) =>
    return cb new Error "organizationId parameter is required." unless organizationId
    mongooseRestHelper.getById @models.Organization,organizationId,null,options, cb


  ###
  Completely destroys an organization.
  ###
  destroy: (organizationId,options = {}, cb = ->) =>
    return cb new Error "organizationId parameter is required." unless organizationId
    settings = {}
    mongooseRestHelper.destroy @models.Organization,organizationId, settings,{}, cb

  getByName: (_tenantId, name, options = {}, cb = ->) =>
    if _.isFunction(options)
      cb = options 
      options = {}

    @models.Organization.findOne name: name , (err, item) =>
      return cb err if err
      cb null, item

  getByNameOrId: (_tenantId, nameOrId, options = {},cb = ->) =>
    if _.isFunction(options)
      cb = options 
      options = {}


    if isObjectId(nameOrId)
      @get nameOrId, cb
    else
      @getByName nameOrId, cb

  ###
  Patch an organization
  ###
  patch: (organizationId, obj = {}, options = {}, cb = ->) =>
    return cb new Error "organizationId parameter is required." unless organizationId
    settings =
      exclude : UPDATE_EXCLUDEFIELDS
    mongooseRestHelper.patch @models.Organization,organizationId, settings, obj, options, cb


  ###
  Creates a new organization.
  ###
  create: (_tenantId, objs = {},options = {}, cb = ->) =>
    return cb new Error "_tenantId parameter is required." unless _tenantId
    objs._tenantId = new ObjectId _tenantId.toString()

    settings = {}
    mongooseRestHelper.create @models.Organization,settings,objs,options,cb



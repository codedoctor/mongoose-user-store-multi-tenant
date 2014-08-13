_ = require 'underscore-ext'
errors = require 'some-errors'
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId
mongooseRestHelper = require 'mongoose-rest-helper'
i18n = require '../i18n'


module.exports = class RoleMethods
  UPDATE_EXCLUDEFIELDS = ['_id']

  constructor:(@models) ->

  all: (_tenantId,options = {},cb = ->) =>
    return cb new Error "_tenantId parameter is required." unless _tenantId

    settings = 
        baseQuery:
          _tenantId : mongooseRestHelper.asObjectId _tenantId
        defaultSort: 'name'
        defaultSelect: null
        defaultCount: 1000
    mongooseRestHelper.all @models.Role,settings,options, cb

  ###
  Get a role for its id.
  ###
  get: (roleId,options = {}, cb = ->) =>
    return cb new Error "roleId parameter is required." unless roleId
    mongooseRestHelper.getById @models.Role,roleId,null,options, cb


  ###
  Completely destroys a role.
  ###
  destroy: (roleId, options = {}, cb = ->) =>
    return cb new Error "roleId parameter is required." unless roleId
    settings = {}
    mongooseRestHelper.destroy @models.Role,roleId, settings,{}, cb


  ###
  Create a new role.
  ###
  create:(_tenantId,objs = {}, options = {}, cb = ->) =>
    return cb new Error "_tenantId parameter is required." unless _tenantId
    settings = {}
    objs._tenantId = new ObjectId _tenantId.toString()
    mongooseRestHelper.create @models.Role,settings,objs,options,cb


  ###
  Updates a role.
  ###
  patch: (roleId, obj = {}, options = {}, cb = ->) =>
    return cb new Error "scopeId parameter is required." unless scopeId
    settings =
      exclude : UPDATE_EXCLUDEFIELDS
    mongooseRestHelper.patch @models.Role,roleId, settings, obj, options, cb





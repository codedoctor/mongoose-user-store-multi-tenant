_ = require 'underscore-ext'
mongooseRestHelper = require 'mongoose-rest-helper'
i18n = require '../i18n'
Hoek = require 'hoek'
Boom = require 'boom'

fnUnprocessableEntity = (message = "",data) ->
  return Boom.create 422, message, data


module.exports = class RoleMethods
  UPDATE_EXCLUDEFIELDS = ['_id']

  constructor:(@models) ->
    Hoek.assert @models,i18n.assertModelsRequired
    Hoek.assert @models.Role,i18n.assertRoleInModelsRequired

  all: (_tenantId,options = {},cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

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
    return cb fnUnprocessableEntity( i18n.errorRoleIdRequired) unless roleId
    mongooseRestHelper.getById @models.Role,roleId,null,options, cb


  ###
  Completely destroys a role.
  ###
  destroy: (roleId, options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorRoleIdRequired) unless roleId
    settings = {}
    mongooseRestHelper.destroy @models.Role,roleId, settings,{}, cb


  ###
  Create a new role.
  ###
  create:(_tenantId,objs = {}, options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorTenantIdRequired) unless _tenantId

    settings = {}
    objs._tenantId = mongooseRestHelper.asObjectId _tenantId
    mongooseRestHelper.create @models.Role,settings,objs,options,cb


  ###
  Updates a role.
  ###
  patch: (roleId, obj = {}, options = {}, cb = ->) =>
    return cb fnUnprocessableEntity( i18n.errorRoleIdRequired) unless roleId

    settings =
      exclude : UPDATE_EXCLUDEFIELDS
    mongooseRestHelper.patch @models.Role,roleId, settings, obj, options, cb


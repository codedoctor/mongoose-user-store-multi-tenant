_ = require 'underscore-ext'
Boom = require 'boom'
Hoek = require 'hoek'
mongooseRestHelper = require 'mongoose-rest-helper'
{isObjectId} = require 'mongodb-objectid-helper'

i18n = require '../i18n'

module.exports = class UserProviderMethods

  ###
  Initializes a new instance of the @see AdminMethods class.
  @param {Object} models A collection of models that can be used.
  ###
  constructor:(@models) ->
    Hoek.assert @models,i18n.assertModelsRequired
 

  ###
  Gets or creates a user for a given provider/profile combination.
  @param {String} provider a provider string like "facebook" or "twitter".
  @param {String} v1 the key or access_token, depending on the type of provider
  @param {String} v2 the secret or refresh_token, depending on the type of provider
  @param {Object} profile The profile as defined here: http://passportjs.org/guide/user-profile.html
  ###
  getUserFromProvider: (_tenantId,provider, key, options = {}, cb = ->) =>
    return cb Boom.badRequest( i18n.errorTenantIdRequired) unless _.isString(_tenantId)
    return cb fnUnprocessableEntity( i18n.errorProviderRequired) unless _.isString(provider)
    return cb fnUnprocessableEntity( i18n.errorKeyRequired) unless _.isString(key)

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId

    identityQuery =
      _tenantId : _tenantId
      'identities.provider': provider
      'identities.key': key

    @models.User.findOne identityQuery , (err, user) =>
      return cb err if err
      return cb null, user


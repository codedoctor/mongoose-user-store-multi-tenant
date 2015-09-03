(function() {
  var Boom, Hoek, UserProviderMethods, _, i18n, isObjectId, mongooseRestHelper,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require('underscore-ext');

  Boom = require('boom');

  Hoek = require('hoek');

  mongooseRestHelper = require('mongoose-rest-helper');

  isObjectId = require('mongodb-objectid-helper').isObjectId;

  i18n = require('../i18n');


  /*
  Provides methods that deal with the provider related part of a user.
   */

  module.exports = UserProviderMethods = (function() {

    /*
    Initializes a new instance of the @see AdminMethods class.
    @param {Object} models A collection of models that can be used.
     */
    function UserProviderMethods(models) {
      this.models = models;
      this.getUserFromProvider = bind(this.getUserFromProvider, this);
      Hoek.assert(this.models, i18n.assertModelsRequired);
    }


    /*
    Gets or creates a user for a given provider/profile combination.
    @param {String} provider a provider string like "facebook" or "twitter".
    @param {String} v1 the key or access_token, depending on the type of provider
    @param {String} v2 the secret or refresh_token, depending on the type of provider
    @param {Object} profile The profile as defined here: http://passportjs.org/guide/user-profile.html
     */

    UserProviderMethods.prototype.getUserFromProvider = function(_tenantId, provider, key, options, cb) {
      var identityQuery;
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_.isString(_tenantId)) {
        return cb(Boom.badRequest(i18n.errorTenantIdRequired));
      }
      if (!_.isString(provider)) {
        return cb(fnUnprocessableEntity(i18n.errorProviderRequired));
      }
      if (!_.isString(key)) {
        return cb(fnUnprocessableEntity(i18n.errorKeyRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      identityQuery = {
        _tenantId: _tenantId,
        'identities.provider': provider,
        'identities.key': key
      };
      return this.models.User.findOne(identityQuery, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          return cb(null, user);
        };
      })(this));
    };

    return UserProviderMethods;

  })();

}).call(this);

//# sourceMappingURL=user-provider-methods.js.map

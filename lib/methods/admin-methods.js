(function() {
  var AdminMethods, Boom, Hoek, fnUnprocessableEntity, i18n, mongooseRestHelper, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require('underscore-ext');

  Boom = require('boom');

  Hoek = require('hoek');

  mongooseRestHelper = require('mongoose-rest-helper');

  i18n = require('../i18n');

  fnUnprocessableEntity = function(message, data) {
    if (message == null) {
      message = "";
    }
    return Boom.create(422, message, data);
  };


  /*
  Provides methods to set up admin users.
   */

  module.exports = AdminMethods = (function() {

    /*
    Initializes a new instance of the @see ScottyMethods class.
    @param {Object} models A collection of models that can be used.
     */
    function AdminMethods(models, userMethods) {
      this.models = models;
      this.userMethods = userMethods;
      this.setup = __bind(this.setup, this);
      Hoek.assert(this.models, i18n.assertModelsRequired);
      Hoek.assert(this.models, i18n.assertUserMethodsRequired);
    }


    /*
    Sets up an account ready for use.
     */

    AdminMethods.prototype.setup = function(_tenantId, username, email, password, roles, options, cb) {
      var adminUser;
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (!username) {
        return cb(fnUnprocessableEntity(i18n.errorUsernameRequired));
      }
      if (!email) {
        return cb(fnUnprocessableEntity(i18n.errorEmailRequired));
      }
      if (!password) {
        return cb(fnUnprocessableEntity(i18n.errorPasswordRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      adminUser = {
        _tenantId: _tenantId,
        username: username,
        password: password,
        displayName: 'ADMIN',
        roles: roles || ['admin', 'serveradmin'],
        email: email
      };
      return this.userMethods.create(_tenantId, adminUser, {}, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          return cb(null, user);
        };
      })(this));
    };

    return AdminMethods;

  })();

}).call(this);

//# sourceMappingURL=admin-methods.js.map

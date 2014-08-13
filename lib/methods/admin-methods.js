(function() {
  var AdminMethods, ObjectId, async, bcrypt, errors, mongoose, passgen, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require('underscore-ext');

  errors = require('some-errors');

  mongoose = require("mongoose");

  ObjectId = mongoose.Types.ObjectId;

  bcrypt = require('bcryptjs');

  passgen = require('passgen');

  async = require('async');


  /*
  Provides methods to interact with scotties.
   */

  module.exports = AdminMethods = (function() {

    /*
    Initializes a new instance of the @see ScottyMethods class.
    @param {Object} models A collection of models that can be used.
     */
    function AdminMethods(models, users) {
      this.models = models;
      this.users = users;
      this.setup = __bind(this.setup, this);
      if (!this.models) {
        throw new Error("models parameter is required");
      }
      if (!this.users) {
        throw new Error("users parameter is required");
      }
    }


    /*
    Sets up an account ready for use.
     */

    AdminMethods.prototype.setup = function(_tenantId, appName, username, email, password, scopes, clientId, secret, options, cb) {
      var adminUser;
      if (scopes == null) {
        scopes = [];
      }
      if (clientId == null) {
        clientId = null;
      }
      if (secret == null) {
        secret = null;
      }
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(new Error("_tenantId parameter is required."));
      }
      if (!appName) {
        return cb(new Error("appName parameter is required."));
      }
      if (!username) {
        return cb(new Error("username parameter is required."));
      }
      if (!email) {
        return cb(new Error("email parameter is required."));
      }
      if (!password) {
        return cb(new Error("password parameter is required."));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = new ObjectId(_tenantId.toString());
      adminUser = {
        _tenantId: _tenantId,
        username: username,
        password: password,
        displayName: 'ADMIN',
        roles: ['admin', 'serveradmin'],
        email: email
      };
      return this.users.create(_tenantId, adminUser, {}, (function(_this) {
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

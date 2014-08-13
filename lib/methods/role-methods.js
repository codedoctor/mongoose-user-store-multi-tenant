(function() {
  var Boom, Hoek, ObjectId, RoleMethods, errors, fnUnprocessableEntity, i18n, mongoose, mongooseRestHelper, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require('underscore-ext');

  errors = require('some-errors');

  mongoose = require("mongoose");

  ObjectId = mongoose.Types.ObjectId;

  mongooseRestHelper = require('mongoose-rest-helper');

  i18n = require('../i18n');

  Hoek = require('hoek');

  Boom = require('boom');

  fnUnprocessableEntity = function(message, data) {
    if (message == null) {
      message = "";
    }
    return Boom.create(422, message, data);
  };

  module.exports = RoleMethods = (function() {
    var UPDATE_EXCLUDEFIELDS;

    UPDATE_EXCLUDEFIELDS = ['_id'];

    function RoleMethods(models) {
      this.models = models;
      this.patch = __bind(this.patch, this);
      this.create = __bind(this.create, this);
      this.destroy = __bind(this.destroy, this);
      this.get = __bind(this.get, this);
      this.all = __bind(this.all, this);
      Hoek.assert(this.models, i18n.assertModelsRequired);
    }

    RoleMethods.prototype.all = function(_tenantId, options, cb) {
      var settings;
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      settings = {
        baseQuery: {
          _tenantId: mongooseRestHelper.asObjectId(_tenantId)
        },
        defaultSort: 'name',
        defaultSelect: null,
        defaultCount: 1000
      };
      return mongooseRestHelper.all(this.models.Role, settings, options, cb);
    };


    /*
    Get a role for its id.
     */

    RoleMethods.prototype.get = function(roleId, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!roleId) {
        return cb(new Error("roleId parameter is required."));
      }
      return mongooseRestHelper.getById(this.models.Role, roleId, null, options, cb);
    };


    /*
    Completely destroys a role.
     */

    RoleMethods.prototype.destroy = function(roleId, options, cb) {
      var settings;
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!roleId) {
        return cb(new Error("roleId parameter is required."));
      }
      settings = {};
      return mongooseRestHelper.destroy(this.models.Role, roleId, settings, {}, cb);
    };


    /*
    Create a new role.
     */

    RoleMethods.prototype.create = function(_tenantId, objs, options, cb) {
      var settings;
      if (objs == null) {
        objs = {};
      }
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      settings = {};
      objs._tenantId = new ObjectId(_tenantId.toString());
      return mongooseRestHelper.create(this.models.Role, settings, objs, options, cb);
    };


    /*
    Updates a role.
     */

    RoleMethods.prototype.patch = function(roleId, obj, options, cb) {
      var settings;
      if (obj == null) {
        obj = {};
      }
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!roleId) {
        return cb(new Error("roleId parameter is required."));
      }
      settings = {
        exclude: UPDATE_EXCLUDEFIELDS
      };
      return mongooseRestHelper.patch(this.models.Role, roleId, settings, obj, options, cb);
    };

    return RoleMethods;

  })();

}).call(this);

//# sourceMappingURL=role-methods.js.map

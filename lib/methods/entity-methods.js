(function() {
  var Boom, EntityMethods, Hoek, fnUnprocessableEntity, i18n, isObjectId, mongooseRestHelper, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require('underscore-ext');

  mongooseRestHelper = require('mongoose-rest-helper');

  i18n = require('../i18n');

  Hoek = require('hoek');

  Boom = require('boom');

  isObjectId = require('mongodb-objectid-helper').isObjectId;

  fnUnprocessableEntity = function(message, data) {
    if (message == null) {
      message = "";
    }
    return Boom.create(422, message, data);
  };


  /*
  Provides methods to interact with scotties.
   */

  module.exports = EntityMethods = (function() {

    /*
    Initializes a new instance of the @see ScottyMethods class.
    @param {Object} models A collection of models that can be used.
     */
    function EntityMethods(models) {
      this.models = models;
      this.getByNameOrId = __bind(this.getByNameOrId, this);
      this.getByName = __bind(this.getByName, this);
      this.get = __bind(this.get, this);
      Hoek.assert(this.models, i18n.assertModelsRequired);
    }


    /*
    Looks up a user or organization by id. Users are first.
     */

    EntityMethods.prototype.get = function(userIdOrOrganizationId, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!userIdOrOrganizationId) {
        return cb(fnUnprocessableEntity(i18n.errorUserIdOrOrganizationIdRequired));
      }
      return mongooseRestHelper.getById(this.models.User, userIdOrOrganizationId, null, options, (function(_this) {
        return function(err, item) {
          if (err) {
            return cb(err);
          }
          if (item) {
            return cb(null, item);
          }
          return mongooseRestHelper.getById(_this.models.Organization, userIdOrOrganizationId, null, options, cb);
        };
      })(this));
    };


    /*
    @TODO resthelper implementation
     */

    EntityMethods.prototype.getByName = function(_tenantId, name, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (!name) {
        return cb(fnUnprocessableEntity(i18n.errorNameRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      return this.models.User.findOne({
        _tenantId: _tenantId,
        username: name
      }, (function(_this) {
        return function(err, item) {
          if (err) {
            return cb(err);
          }
          if (item) {
            return cb(null, item);
          }
          return _this.models.Organization.findOne({
            _tenantId: _tenantId,
            name: name
          }, function(err, item) {
            if (err) {
              return cb(err);
            }
            return cb(null, item);
          });
        };
      })(this));
    };


    /*
    @TODO resthelper implementation
     */

    EntityMethods.prototype.getByNameOrId = function(_tenantId, nameOrId, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (!nameOrId) {
        return cb(fnUnprocessableEntity(i18n.errorNameOrIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      if (isObjectId(nameOrId)) {
        return this.get(nameOrId, options, cb);
      } else {
        return this.getByName(_tenantId, nameOrId, options, cb);
      }
    };

    return EntityMethods;

  })();

}).call(this);

//# sourceMappingURL=entity-methods.js.map

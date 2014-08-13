(function() {
  var Boom, Hoek, OrganizationMethods, i18n, isObjectId, mongooseRestHelper, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require('underscore-ext');

  mongooseRestHelper = require('mongoose-rest-helper');

  i18n = require('../i18n');

  Hoek = require('hoek');

  Boom = require('boom');

  isObjectId = require('mongodb-objectid-helper').isObjectId;


  /*
  Provides methods to interact with organizations.
   */

  module.exports = OrganizationMethods = (function() {
    var UPDATE_EXCLUDEFIELDS;

    UPDATE_EXCLUDEFIELDS = ['_id', 'createdByUserId', 'createdAt'];


    /*
    Initializes a new instance of the @see OrganizationMethods class.
    @param {Object} models A collection of models that can be used.
     */

    function OrganizationMethods(models) {
      this.models = models;
      this.create = __bind(this.create, this);
      this.patch = __bind(this.patch, this);
      this.getByNameOrId = __bind(this.getByNameOrId, this);
      this.getByName = __bind(this.getByName, this);
      this.destroy = __bind(this.destroy, this);
      this.get = __bind(this.get, this);
      this.all = __bind(this.all, this);
      Hoek.assert(this.models, i18n.assertModelsRequired);
      Hoek.assert(this.models.Organization, i18n.assertOrganizationInModelsRequired);
    }

    OrganizationMethods.prototype.all = function(_tenantId, options, cb) {
      var settings;
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(Boom.badRequest(i18n.errorTenantIdRequired));
      }
      settings = {
        baseQuery: {
          _tenantId: mongooseRestHelper.asObjectId(_tenantId)
        },
        defaultSort: 'name',
        defaultSelect: null,
        defaultCount: 1000
      };
      return mongooseRestHelper.all(this.models.Organization, settings, options, cb);
    };


    /*
    Looks up an organization by id.
     */

    OrganizationMethods.prototype.get = function(organizationId, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!organizationId) {
        return cb(Boom.badRequest(i18n.errorOrganizationIdRequired));
      }
      return mongooseRestHelper.getById(this.models.Organization, organizationId, null, options, cb);
    };


    /*
    Completely destroys an organization.
     */

    OrganizationMethods.prototype.destroy = function(organizationId, options, cb) {
      var settings;
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!organizationId) {
        return cb(Boom.badRequest(i18n.errorOrganizationIdRequired));
      }
      settings = {};
      return mongooseRestHelper.destroy(this.models.Organization, organizationId, settings, {}, cb);
    };

    OrganizationMethods.prototype.getByName = function(_tenantId, name, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(Boom.badRequest(i18n.errorTenantIdRequired));
      }
      if (!name) {
        return cb(Boom.badRequest(i18n.errorNameRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      return this.models.Organization.findOne({
        name: name
      }, (function(_this) {
        return function(err, item) {
          if (err) {
            return cb(err);
          }
          return cb(null, item);
        };
      })(this));
    };

    OrganizationMethods.prototype.getByNameOrId = function(_tenantId, nameOrId, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(Boom.badRequest(i18n.errorTenantIdRequired));
      }
      if (!nameOrId) {
        return cb(Boom.badRequest(i18n.errorNameOrIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      if (isObjectId(nameOrId)) {
        return this.get(nameOrId, cb);
      } else {
        return this.getByName(nameOrId, cb);
      }
    };


    /*
    Patches an organization
     */

    OrganizationMethods.prototype.patch = function(organizationId, obj, options, cb) {
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
      if (!organizationId) {
        return cb(Boom.badRequest(i18n.errorOrganizationIdRequired));
      }
      settings = {
        exclude: UPDATE_EXCLUDEFIELDS
      };
      return mongooseRestHelper.patch(this.models.Organization, organizationId, settings, obj, options, cb);
    };


    /*
    Creates a new organization.
     */

    OrganizationMethods.prototype.create = function(_tenantId, objs, options, cb) {
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
        return cb(Boom.badRequest(i18n.errorTenantIdRequired));
      }
      objs._tenantId = mongooseRestHelper.asObjectId(_tenantId);
      settings = {};
      return mongooseRestHelper.create(this.models.Organization, settings, objs, options, cb);
    };

    return OrganizationMethods;

  })();

}).call(this);

//# sourceMappingURL=organization-methods.js.map

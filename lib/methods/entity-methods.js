(function() {
  var EntityMethods, ObjectId, PageResult, bcrypt, errors, isObjectId, mongoose, mongooseRestHelper, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require('underscore-ext');

  errors = require('some-errors');

  PageResult = require('simple-paginator').PageResult;

  mongoose = require("mongoose");

  ObjectId = mongoose.Types.ObjectId;

  bcrypt = require('bcryptjs');

  mongooseRestHelper = require('mongoose-rest-helper');

  isObjectId = require('mongodb-objectid-helper').isObjectId;


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
      if (!this.models) {
        throw new Error("models parameter is required");
      }
    }


    /*
    Looks up a user or organization by id. Users are first.
     */

    EntityMethods.prototype.get = function(id, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!id) {
        return cb(new Error("id parameter is required."));
      }
      return mongooseRestHelper.getById(this.models.User, id, null, options, (function(_this) {
        return function(err, item) {
          if (err) {
            return cb(err);
          }
          if (item) {
            return cb(null, item);
          }
          return mongooseRestHelper.getById(_this.models.Organization, id, null, options, cb);
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
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = new ObjectId(_tenantId.toString());
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
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = new ObjectId(_tenantId.toString());
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
